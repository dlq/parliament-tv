"""Parser for New Zealand Parliament's public calendar page."""

from __future__ import annotations

from datetime import UTC, datetime

from .common import checked_label, clean_html, first_match

SOURCE = {
    "id": "new-zealand-parliament",
    "channel_ids": ["new-zealand-parliament"],
    "url": "https://www3.parliament.nz/en/calendar/",
    "method": "GET",
    "headers": {"User-Agent": "Mozilla/5.0"},
    "notes": "Extracts the House next meets text from the official calendar page.",
}


def parse(html: str, now: datetime | None = None) -> dict:
    if "house next meets" not in html.lower():
        return {}
    body = clean_html(html)
    next_text = first_match(body, r"The\s+House next meets\s+(?:on\s+)?([^\.]+\.?)")
    next_text = next_text or first_match(body, r"House next meets\s+(?:on\s+)?([^\.]+\.?)")
    return {
        "new-zealand-parliament": {
            "current_event_title": "House not currently listed live",
            "current_event_time": checked_label(now or datetime.now(UTC)),
            "next_event_title": "House next meets",
            "next_event_time": next_text,
            "confidence": "official_calendar",
        }
    }
