#!/usr/bin/env python3
"""Generate the Flutter-distributed configuration asset from local .env.

Only the names in ALLOWED_KEYS are copied. The source .env remains available
to local tooling and is never bundled by Flutter.
"""

from __future__ import annotations

import argparse
import base64
import binascii
import json
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ALLOWED_KEYS = frozenset({
    "AANGAN_BELL_AUDIO_URL",
    "GOOGLE_IOS_CLIENT_ID",
    "GOOGLE_WEB_CLIENT_ID",
    "LEGAL_PRIVACY_URL",
    "LEGAL_TERMS_URL",
    "PREMIUM_GRANT_ALL",
    "REVENUECAT_API_KEY",
    "REVENUECAT_API_KEY_ANDROID",
    "REVENUECAT_API_KEY_IOS",
    "REVENUECAT_DEBUG_MODE",
    "REVENUECAT_ENTITLEMENT_ID",
    "REVENUECAT_PLUS_ENTITLEMENT_ID",
    "REVENUECAT_PRO_ENTITLEMENT_ID",
    "REVENUECAT_TEST_STORE_API_KEY",
    "REVENUECAT_USE_TEST_STORE",
    "SUPABASE_ANON_KEY",
    "SUPABASE_AUTH_REDIRECT_URL",
    "SUPABASE_URL",
})

BOOL_KEYS = frozenset({
    "PREMIUM_GRANT_ALL",
    "REVENUECAT_DEBUG_MODE",
    "REVENUECAT_USE_TEST_STORE",
})
URL_KEYS = frozenset({
    "AANGAN_BELL_AUDIO_URL",
    "LEGAL_PRIVACY_URL",
    "LEGAL_TERMS_URL",
    "SUPABASE_URL",
})
REVENUECAT_KEY_KEYS = frozenset({
    "REVENUECAT_API_KEY",
    "REVENUECAT_API_KEY_ANDROID",
    "REVENUECAT_API_KEY_IOS",
    "REVENUECAT_TEST_STORE_API_KEY",
})
FORBIDDEN_MARKERS = (
    "confluence", "service_role", "supabase_service_role", "openai_api_key",
    "private_key", "client_secret", "access_token", "refresh_token",
    "password", "secret_key", "sk-", "sk_",
)


class ConfigError(ValueError):
    """A source value is unsafe or unsuitable for a distributed app asset."""


def parse_dotenv(path: Path) -> dict[str, str]:
    """Parse the simple KEY=VALUE format supported by flutter_dotenv."""
    values: dict[str, str] = {}
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except FileNotFoundError as exc:
        raise ConfigError(f"Configuration source is missing: {path}") from exc

    for number, raw_line in enumerate(lines, start=1):
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("export "):
            line = line[7:].lstrip()
        if "=" not in line:
            raise ConfigError(f"Invalid configuration assignment on line {number}")
        name, value = line.split("=", 1)
        name = name.strip()
        if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", name):
            raise ConfigError(f"Invalid configuration name on line {number}")
        value = value.strip()
        if re.search(r"\$(?:\{[A-Za-z_][A-Za-z0-9_]*\}|[A-Za-z_][A-Za-z0-9_]*)", value):
            raise ConfigError(
                f"Configuration interpolation is unsupported on line {number}; use a literal value"
            )
        if len(value) >= 2 and value[0] == value[-1] and value[0] in {"'", '"'}:
            value = value[1:-1]
        values[name] = value
    return values


def _decode_jwt_payload(value: str) -> dict[str, object] | None:
    """Decode JWT JSON only to validate public-key format and role offline."""
    parts = value.split(".")
    if len(parts) != 3 or any(not part or not re.fullmatch(r"[A-Za-z0-9_-]+", part) for part in parts):
        return None
    try:
        header_part, payload_part, _signature = parts
        header = base64.urlsafe_b64decode(
            (header_part + "=" * (-len(header_part) % 4)).encode("ascii")
        ).decode("utf-8")
        payload = base64.urlsafe_b64decode(
            (payload_part + "=" * (-len(payload_part) % 4)).encode("ascii")
        ).decode("utf-8")
        if not isinstance(json.loads(header), dict):
            return None
        decoded_payload = json.loads(payload)
    except (UnicodeDecodeError, ValueError, binascii.Error, json.JSONDecodeError):
        return None
    return decoded_payload if isinstance(decoded_payload, dict) else None


def _is_public_supabase_key(value: str) -> bool:
    if value.startswith("sb_publishable_"):
        return len(value) > len("sb_publishable_")
    payload = _decode_jwt_payload(value)
    return payload is not None and payload.get("role") == "anon"


def validate_value(name: str, value: str) -> None:
    """Reject known private credentials and enforce public config formats."""
    lower_value = value.lower()
    if any(marker in lower_value for marker in FORBIDDEN_MARKERS):
        raise ConfigError(f"{name} contains a private or service-role credential")
    if name == "SUPABASE_ANON_KEY" and value and not _is_public_supabase_key(value):
        raise ConfigError("SUPABASE_ANON_KEY must be an sb_publishable_ key or JWT with role anon")
    if name in BOOL_KEYS and value.lower() not in {"true", "false"}:
        raise ConfigError(f"{name} must be true or false")
    if name in URL_KEYS and value and not value.startswith("https://"):
        raise ConfigError(f"{name} must use an https URL")
    if name == "SUPABASE_AUTH_REDIRECT_URL" and value and not re.match(r"^[a-z][a-z0-9+.-]*://", value, re.I):
        raise ConfigError("SUPABASE_AUTH_REDIRECT_URL must be a URL")
    if name in {"GOOGLE_WEB_CLIENT_ID", "GOOGLE_IOS_CLIENT_ID"} and value:
        if not value.endswith(".apps.googleusercontent.com"):
            raise ConfigError(f"{name} is not a Google OAuth client ID")
    if name in REVENUECAT_KEY_KEYS and value:
        prefixes = ("appl_", "goog_", "test_")
        if not value.startswith(prefixes):
            raise ConfigError(f"{name} is not a RevenueCat public SDK key")


def safe_app_values(values: dict[str, str]) -> dict[str, str]:
    """Return only validated values intended for a client-side app bundle."""
    output: dict[str, str] = {}
    for name in sorted(ALLOWED_KEYS):
        if name not in values:
            continue
        value = values[name]
        validate_value(name, value)
        output[name] = value
    return output


def render_dotenv(values: dict[str, str]) -> str:
    """Render values without shell interpolation or comments that could leak data."""
    for name, value in values.items():
        if "\n" in value or "\r" in value:
            raise ConfigError(f"{name} must be a single-line value")
    return "".join(f"{name}={value}\n" for name, value in sorted(values.items()))


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Generate allowlisted .env.app for Flutter.")
    parser.add_argument("--source", type=Path, default=ROOT / ".env")
    parser.add_argument("--output", type=Path, default=ROOT / ".env.app")
    args = parser.parse_args(argv)
    try:
        rendered = render_dotenv(safe_app_values(parse_dotenv(args.source)))
        args.output.write_text(rendered, encoding="utf-8")
    except (ConfigError, OSError) as exc:
        print(f"App config preparation failed: {exc}", file=sys.stderr)
        return 1
    print(f"Prepared {args.output.name} with allowlisted app configuration.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
