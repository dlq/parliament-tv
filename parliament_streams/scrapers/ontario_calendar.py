"""Parser for the Ontario Legislative Assembly calendar page."""

from __future__ import annotations

import re
from datetime import UTC, datetime

from .common import checked_label, clean_html, local_time_label, parse_iso

CHANNEL_IDS = [
    "ontario-house-en",
    "ontario-house-en-cc",
    "ontario-rm151-en",
    "ontario-committee-1-en",
    "ontario-committee-2-en",
    "ontario-media-en",
]

SOURCE = {
    "id": "ontario-calendar",
    "channel_ids": CHANNEL_IDS,
    "url": "https://www.ola.org/en/legislative-business/calendar",
    "method": "GET",
    "headers": {"User-Agent": "Mozilla/5.0"},
    "notes": "Extracts dated event headings from the official OLA calendar.",
}


def parse(html: str, now: datetime | None = None) -> dict:
    now = now or datetime.now(UTC)
    events = []
    pattern = re.compile(
        r'<time[^>]*datetime="([^"]+)"[^>]*>[\s\S]*?</time>[\s\S]*?'
        r"<h[1-6][^>]*>([\s\S]*?)</h[1-6]>",
        re.IGNORECASE,
    )
    for date_text, title_html in pattern.findall(html):
        start = parse_iso(date_text)
        title = clean_html(title_html)
        if start and title:
            events.append({"start": start, "title": title})
    events.sort(key=lambda item: item["start"])

    if not events:
        if "there are no events today" not in html.lower():
            return {}
        metadata = {
            "current_event_title": "No calendar events listed today",
            "current_event_time": checked_label(now),
            "next_event_title": None,
            "next_event_time": None,
            "confidence": "official_calendar",
        }
        return {channel_id: metadata for channel_id in CHANNEL_IDS}

    current_index = 0
    for index, event in enumerate(events):
        if event["start"] <= now:
            current_index = index
        else:
            break
    current = events[current_index]
    next_event = events[current_index + 1] if current_index + 1 < len(events) else None
    metadata = {
        "current_event_title": current["title"],
        "current_event_time": local_time_label(current["start"]),
        "next_event_title": next_event["title"] if next_event else None,
        "next_event_time": local_time_label(next_event["start"]) if next_event else None,
        "confidence": "official_calendar",
    }
    return {channel_id: metadata for channel_id in CHANNEL_IDS}
