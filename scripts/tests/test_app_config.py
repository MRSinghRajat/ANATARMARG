#!/usr/bin/env python3
"""Tests use synthetic config only; never read the repository .env."""

from __future__ import annotations

import base64
import sys
import tempfile
import unittest
import zipfile
from pathlib import Path

SCRIPTS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(SCRIPTS))

from prepare_app_config import ConfigError, main as prepare_main, parse_dotenv, render_dotenv, safe_app_values
from verify_app_config import verify_config, verify_package


def _jwt(payload: str) -> str:
    def encode(value: str) -> str:
        return base64.urlsafe_b64encode(value.encode("utf-8")).decode("ascii").rstrip("=")

    header = encode('{"alg":"HS256"}')
    return f"{header}.{encode(payload)}.signature"


def _release_config(extra: str = "") -> str:
    return (
        "SUPABASE_URL=https://example.supabase.co\n"
        "SUPABASE_ANON_KEY=sb_publishable_synthetic\n"
        "REVENUECAT_API_KEY_IOS=appl_synthetic\n"
        + extra
    )


class AppConfigTests(unittest.TestCase):
    def test_allowlist_excludes_tooling_credentials(self) -> None:
        source = {
            "SUPABASE_URL": "https://example.supabase.co",
            "SUPABASE_ANON_KEY": _jwt('{"role":"anon"}'),
            "CONFLUENCE_API_TOKEN": "synthetic-private-token",
            "OPENAI_API_KEY": "sk_synthetic",
        }
        values = safe_app_values(source)
        self.assertEqual(set(values), {"SUPABASE_URL", "SUPABASE_ANON_KEY"})
        self.assertNotIn("CONFLUENCE_API_TOKEN", render_dotenv(values))

    def test_non_anon_jwt_roles_are_rejected(self) -> None:
        for role in ("service_role", "authenticated"):
            with self.subTest(role=role), self.assertRaisesRegex(ConfigError, "role anon"):
                safe_app_values({"SUPABASE_ANON_KEY": _jwt(f'{{"role":"{role}"}}')})

    def test_supabase_anon_jwt_allows_json_whitespace(self) -> None:
        key = _jwt('{\n\t"role": \n\t"anon"\n}')
        self.assertEqual(safe_app_values({"SUPABASE_ANON_KEY": key}), {"SUPABASE_ANON_KEY": key})

    def test_supabase_publishable_key_is_allowed(self) -> None:
        key = "sb_publishable_synthetic"
        self.assertEqual(safe_app_values({"SUPABASE_ANON_KEY": key}), {"SUPABASE_ANON_KEY": key})

    def test_supabase_secret_and_arbitrary_keys_are_rejected(self) -> None:
        for key in ("sb_secret_synthetic", "arbitrary-key-in-the-wrong-setting"):
            with self.subTest(key=key), self.assertRaisesRegex(ConfigError, "SUPABASE_ANON_KEY"):
                safe_app_values({"SUPABASE_ANON_KEY": key})

    def test_generator_writes_only_allowlisted_values(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / ".env"
            output = Path(directory) / ".env.app"
            source.write_text(
                "SUPABASE_URL=https://example.supabase.co\n"
                "CONFLUENCE_API_TOKEN=synthetic-private-token\n"
            )
            self.assertEqual(prepare_main(["--source", str(source), "--output", str(output)]), 0)
            self.assertEqual(output.read_text(), "SUPABASE_URL=https://example.supabase.co\n")

    def test_verifier_rejects_unexpected_name_without_echoing_value(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            config = Path(directory) / ".env.app"
            config.write_text("SUPABASE_URL=https://example.supabase.co\nCONFLUENCE_API_TOKEN=synthetic\n")
            with self.assertRaisesRegex(ConfigError, "non-allowlisted"):
                verify_config(config)

    def test_parser_supports_quoted_values(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            config = Path(directory) / ".env"
            config.write_text("GOOGLE_WEB_CLIENT_ID='123.apps.googleusercontent.com'\n")
            self.assertEqual(parse_dotenv(config)["GOOGLE_WEB_CLIENT_ID"], "123.apps.googleusercontent.com")

    def test_parser_rejects_unsupported_interpolation(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            config = Path(directory) / ".env"
            config.write_text("SUPABASE_URL=${BASE_URL}\n")
            with self.assertRaisesRegex(ConfigError, "interpolation is unsupported"):
                parse_dotenv(config)

    def test_release_verifier_accepts_required_public_config(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            config = Path(directory) / ".env.app"
            config.write_text(_release_config())
            verify_config(config, release=True)

    def test_release_verifier_rejects_enabled_override(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            config = Path(directory) / ".env.app"
            config.write_text(_release_config("PREMIUM_GRANT_ALL=true\n"))
            with self.assertRaisesRegex(ConfigError, "override flag"):
                verify_config(config, release=True)

    def test_release_verifier_rejects_test_store_key(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            config = Path(directory) / ".env.app"
            config.write_text(_release_config("REVENUECAT_TEST_STORE_API_KEY=test_synthetic\n"))
            with self.assertRaisesRegex(ConfigError, "Test Store"):
                verify_config(config, release=True)

    def test_package_verifier_rejects_original_env_asset(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            ipa = Path(directory) / "synthetic.ipa"
            with zipfile.ZipFile(ipa, "w") as archive:
                archive.writestr("Payload/Runner.app/flutter_assets/.env.app", "SUPABASE_URL=https://example.supabase.co\n")
                archive.writestr("Payload/Runner.app/flutter_assets/.env", "CONFLUENCE_API_TOKEN=synthetic\n")
            with self.assertRaisesRegex(ConfigError, "original .env"):
                verify_package(ipa)

    def test_package_verifier_accepts_allowlisted_asset(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            ipa = Path(directory) / "synthetic.ipa"
            with zipfile.ZipFile(ipa, "w") as archive:
                archive.writestr(
                    "Payload/Runner.app/Frameworks/App.framework/flutter_assets/.env.app",
                    _release_config(),
                )
            verify_package(ipa, release=True)


if __name__ == "__main__":
    unittest.main()
