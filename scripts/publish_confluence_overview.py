#!/usr/bin/env python3
"""Publish docs/CONFLUENCE_APP_OVERVIEW.md to Confluence Cloud.

Required environment variables (add to .env or export before running):
  CONFLUENCE_BASE_URL   e.g. https://yourcompany.atlassian.net/wiki
  CONFLUENCE_EMAIL      Atlassian account email
  CONFLUENCE_API_TOKEN  API token from https://id.atlassian.com/manage-profile/security/api-tokens
  CONFLUENCE_SPACE_KEY  Space key (short code shown in space URLs)

Optional:
  CONFLUENCE_PAGE_TITLE       default: Antar Marg — Current State Overview
  CONFLUENCE_PARENT_PAGE_ID   parent page numeric id (creates under that page)
  CONFLUENCE_PAGE_ID          if set, update this page instead of title lookup

Usage:
  pip install -r scripts/requirements-confluence.txt
  python scripts/publish_confluence_overview.py
"""

from __future__ import annotations

import os
import sys
from pathlib import Path

import markdown
from atlassian import Confluence

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "docs" / "CONFLUENCE_APP_OVERVIEW.md"


def _load_dotenv() -> None:
    env_path = ROOT / ".env"
    if not env_path.is_file():
        return
    for line in env_path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, value = line.partition("=")
        os.environ.setdefault(key.strip(), value.strip())


def _require(name: str) -> str:
    value = os.environ.get(name, "").strip()
    if not value:
        print(f"Missing required env var: {name}", file=sys.stderr)
        sys.exit(1)
    return value


def _markdown_to_storage(md: str) -> str:
    html = markdown.markdown(
        md,
        extensions=["tables", "fenced_code", "sane_lists", "nl2br"],
    )
    # Confluence storage accepts basic HTML for many elements.
    return html


def _resolve_space_key(confluence: Confluence, space_key_or_id: str) -> str:
    """Accept a short space key or a long space id from Confluence URLs."""
    try:
        confluence.get_space(space_key_or_id, expand="")
        return space_key_or_id
    except Exception:
        pass

    try:
        spaces = confluence.get_all_spaces(start=0, limit=100)
        if isinstance(spaces, dict):
            space_list = spaces.get("results", [])
        else:
            space_list = list(spaces)
    except Exception:
        space_list = []

    for space in space_list:
        if space.get("key") == space_key_or_id or space.get("id") == space_key_or_id:
            return space["key"]

    print(
        f"Could not resolve Confluence space: {space_key_or_id}",
        file=sys.stderr,
    )
    sys.exit(1)


def _find_page_in_space(confluence: Confluence, space_key: str, title: str):
    cql = f'space="{space_key}" AND title="{title.replace(chr(34), "")}" AND type=page'
    results = confluence.cql(cql, limit=1)
    hits = results.get("results", [])
    if not hits:
        return None
    return hits[0].get("content", hits[0])


def main() -> None:
    _load_dotenv()

    base_url = _require("CONFLUENCE_BASE_URL").rstrip("/")
    email = _require("CONFLUENCE_EMAIL")
    api_token = _require("CONFLUENCE_API_TOKEN")
    space_key = _require("CONFLUENCE_SPACE_KEY")
    title = os.environ.get(
        "CONFLUENCE_PAGE_TITLE", "Antar Marg — Current State Overview"
    ).strip()
    parent_id = os.environ.get("CONFLUENCE_PARENT_PAGE_ID", "").strip() or None
    page_id = os.environ.get("CONFLUENCE_PAGE_ID", "").strip() or None

    if not SOURCE.is_file():
        print(f"Source file not found: {SOURCE}", file=sys.stderr)
        sys.exit(1)

    body = _markdown_to_storage(SOURCE.read_text(encoding="utf-8"))

    confluence = Confluence(
        url=base_url,
        username=email,
        password=api_token,
        cloud=True,
    )

    resolved_space = _resolve_space_key(confluence, space_key)
    parent_id_int = int(parent_id) if parent_id else None

    if page_id:
        confluence.update_page(
            page_id=page_id,
            title=title,
            body=body,
            parent_id=parent_id_int,
            type="page",
            representation="storage",
            minor_edit=False,
            version_comment="Sync from docs/CONFLUENCE_APP_OVERVIEW.md",
        )
    else:
        existing = _find_page_in_space(confluence, resolved_space, title)
        if existing:
            page_id = str(existing["id"])
            confluence.update_page(
                page_id=page_id,
                title=title,
                body=body,
                parent_id=parent_id_int,
                type="page",
                representation="storage",
                minor_edit=False,
                version_comment="Sync from docs/CONFLUENCE_APP_OVERVIEW.md",
            )
        else:
            created = confluence.create_page(
                space=resolved_space,
                title=title,
                body=body,
                parent_id=parent_id_int,
                type="page",
                representation="storage",
                editor="v2",
            )
            page_id = str(created["id"])

    page_url = f"{base_url}/spaces/{resolved_space}/pages/{page_id}"

    print("Published to Confluence.")
    print(f"  Title: {title}")
    print(f"  Page ID: {page_id}")
    print(f"  URL: {page_url}")


if __name__ == "__main__":
    main()
