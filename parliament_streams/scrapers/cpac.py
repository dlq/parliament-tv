"""Parser for CPAC's public schedule page."""

from __future__ import annotations

import re
from datetime import UTC, datetime

from .common import clean_html, local_time_label, parse_iso

SOURCE = {
    "id": "cpac",
    "channel_ids": ["cpac-ca"],
    "url": "https://www.cpac.ca/schedule/",
    "method": "GET",
    "notes": "Parses data-airdate schedule items from CPAC's public schedule page.",
}


def parse(html: str, now: datetime | None = None) -> dict[str, dict]:
    now = now or datetime.now(UTC)
    entries = []
    pattern = re.compile(
        r'data-airdate="([^"]+)"[\s\S]*?'
        r'<button[^>]*class="[^"]*schedule-item-btn[^"]*"[^>]*>([\s\S]*?)</button>',
        re.IGNORECASE,
    )
    for date_text, title_html in pattern.findall(html):
        start = parse_iso(date_text)
        title = clean_html(title_html)
        if start and title:
            entries.append({"start": start, "title": title})

    entries.sort(key=lambda item: item["start"])
    if not entries:
        return {}

    current_index = 0
    for index, entry in enumerate(entries):
        if entry["start"] <= now:
            current_index = index
        else:
            break

    current = entries[current_index]
    next_entry = entries[current_index + 1] if current_index + 1 < len(entries) else None
    return {
        "cpac-ca": {
            "current_event_title": current["title"],
            "current_event_time": local_time_label(current["start"]),
            "next_event_title": next_entry["title"] if next_entry else None,
            "next_event_time": local_time_label(next_entry["start"]) if next_entry else None,
            "confidence": "official_schedule",
        }
    }
