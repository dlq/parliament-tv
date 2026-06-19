"""Small parsing helpers shared by scraper modules."""

from __future__ import annotations

import re
from datetime import UTC, datetime
from html import unescape
from zoneinfo import ZoneInfo

TAG_RE = re.compile(r"<[^>]+>")
SPACE_RE = re.compile(r"\s+")


def clean_html(text: str) -> str:
    """Return readable text from small schedule snippets."""
    text = re.sub(r"<br\s*/?>", " ", text, flags=re.IGNORECASE)
    text = TAG_RE.sub("", text)
    return SPACE_RE.sub(" ", unescape(text)).strip()


def first_match(text: str, pattern: str) -> str | None:
    match = re.search(pattern, text, flags=re.IGNORECASE | re.DOTALL)
    if not match:
        return None
    return match.group(1)


def parse_iso(value: str) -> datetime | None:
    try:
        normalized = value.replace("Z", "+00:00")
        return datetime.fromisoformat(normalized)
    except ValueError:
        return None


def local_time_label(value: datetime, tz_name: str = "America/Toronto") -> str:
    local = value.astimezone(ZoneInfo(tz_name))
    suffix = "ET" if tz_name in {"America/Toronto", "America/New_York"} else local.tzname()
    return f"{local.strftime('%-I:%M %p')} {suffix}"


def checked_label(now: datetime | None = None, tz_name: str = "America/Toronto") -> str:
    now = now or datetime.now(UTC)
    return f"Checked {local_time_label(now, tz_name)}"
