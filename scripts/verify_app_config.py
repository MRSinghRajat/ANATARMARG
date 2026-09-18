#!/usr/bin/env python3
"""Verify that distributed Flutter configuration is allowlisted and safe.

IPA checks prove that the original .env is absent and the bundled .env.app is
allowlisted and valid. The supplementary byte scan checks known credential
names only; it cannot detect arbitrary or encoded secrets elsewhere in a
compiled binary.
"""

from __future__ import annotations

import argparse
import sys
import tempfile
import zipfile
from pathlib import Path

from prepare_app_config import ALLOWED_KEYS, ConfigError, parse_dotenv, safe_app_values


ROOT = Path(__file__).resolve().parents[1]
FORBIDDEN_PACKAGE_MARKERS = (
    b"CONFLUENCE_API_TOKEN", b"SUPABASE_SERVICE_ROLE",
    b"OPENAI_API_KEY", b"CLIENT_SECRET", b"PRIVATE_KEY",
)


def verify_config(path: Path, *, release: bool = False) -> None:
    values = parse_dotenv(path)
    unexpected = sorted(set(values) - ALLOWED_KEYS)
    if unexpected:
        raise ConfigError("App config contains non-allowlisted names")
    safe_app_values(values)
    if release:
        _verify_release_values(values)


def _verify_release_values(values: dict[str, str]) -> None:
    """Enforce TestFlight/App Store requirements without constraining debug runs."""
    required = ("SUPABASE_URL", "SUPABASE_ANON_KEY")
    if any(not values.get(name, "").strip() for name in required):
        raise ConfigError("Release app config is missing required public configuration")

    ios_key = values.get("REVENUECAT_API_KEY_IOS", "").strip() or values.get(
        "REVENUECAT_API_KEY", ""
    ).strip()
    if not ios_key.startswith("appl_"):
        raise ConfigError("Release app config requires an Apple RevenueCat public SDK key (appl_)")

    enabled_flags = (
        "PREMIUM_GRANT_ALL",
        "REVENUECAT_DEBUG_MODE",
        "REVENUECAT_USE_TEST_STORE",
    )
    if any(values.get(name, "").strip().lower() == "true" for name in enabled_flags):
        raise ConfigError("Release app config enables a debug, test, or premium override flag")

    revenuecat_keys = (
        "REVENUECAT_API_KEY",
        "REVENUECAT_API_KEY_ANDROID",
        "REVENUECAT_API_KEY_IOS",
        "REVENUECAT_TEST_STORE_API_KEY",
    )
    if any(values.get(name, "").strip().startswith("test_") for name in revenuecat_keys):
        raise ConfigError("Release app config contains a RevenueCat Test Store key")


def _scan_zip(path: Path, *, release: bool) -> None:
    with zipfile.ZipFile(path) as archive:
        names = archive.namelist()
        unsafe_names = [name for name in names if name.endswith("/.env") or name == ".env"]
        if unsafe_names:
            raise ConfigError("Package contains the original .env asset")
        config_members = [name for name in names if name.endswith("/flutter_assets/.env.app")]
        if len(config_members) != 1:
            raise ConfigError("Package does not contain exactly one .env.app Flutter asset")
        verify_config_bytes(archive.read(config_members[0]), release=release)
        for name in names:
            if archive.getinfo(name).is_dir():
                continue
            data = archive.read(name)
            if any(marker.lower() in data.lower() for marker in FORBIDDEN_PACKAGE_MARKERS):
                raise ConfigError("Package contains a known private-credential marker")


def verify_config_bytes(data: bytes, *, release: bool) -> None:
    with tempfile.TemporaryDirectory(prefix="antarmarg-app-config-") as directory:
        temp_path = Path(directory) / ".env.app"
        temp_path.write_bytes(data)
        verify_config(temp_path, release=release)


def verify_package(path: Path, *, release: bool = False) -> None:
    packages = [path] if path.is_file() else sorted(path.glob("*.ipa"))
    if not packages:
        raise ConfigError("No IPA found to scan")
    for package in packages:
        _scan_zip(package, release=release)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Verify safe Flutter app configuration.")
    parser.add_argument("--config", type=Path, default=ROOT / ".env.app")
    parser.add_argument("--package", type=Path, help="IPA file or directory of IPAs to scan")
    parser.add_argument("--release", action="store_true", help="Enforce TestFlight/App Store requirements")
    args = parser.parse_args(argv)
    try:
        verify_config(args.config, release=args.release)
        if args.package:
            verify_package(args.package, release=args.release)
    except (ConfigError, OSError, zipfile.BadZipFile) as exc:
        print(f"App config verification failed: {exc}", file=sys.stderr)
        return 1
    print("Verified allowlisted app configuration" + (" and IPA package." if args.package else "."))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
