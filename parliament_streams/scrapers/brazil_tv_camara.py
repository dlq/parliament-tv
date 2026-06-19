"""Parser for Brazil TV Camara's weekly schedule page."""

from __future__ import annotations

import re
from datetime import UTC, datetime
from zoneinfo import ZoneInfo

from .common import clean_html, local_time_label

SOURCE = {
    "id": "brazil-tv-camara",
    "channel_ids": ["brazil-tv-camara"],
    "url": "https://www.camara.leg.br/tv/programacao-semanal",
    "method": "GET",
    "headers": {"User-Agent": "Mozilla/5.0"},
    "notes": "Extracts time/title rows from the active tab of TV Camara's weekly schedule.",
}


def parse(html: str, now: datetime | None = None) -> dict:
    now = now or datetime.now(UTC)
    active = _active_tab_html(html) or html
    events = []
    pattern = re.compile(
        r"<tr[^>]*>\s*<td[^>]*>\s*<span[^>]*>(\d{1,2}:\d{2})</span>\s*</td>\s*"
        r"<td[^>]*>\s*<span[^>]*>([\s\S]*?)</span>\s*</td>\s*</tr>",
        re.IGNORECASE,
    )
    source_tz = ZoneInfo("America/Sao_Paulo")
    source_now = now.astimezone(source_tz)
    for time_text, title_html in pattern.findall(active):
        hour, minute = [int(part) for part in time_text.split(":")]
        start = source_now.replace(hour=hour, minute=minute, second=0, microsecond=0)
        title = clean_html(title_html)
        if title:
            events.append({"start": start, "title": title})
    events.sort(key=lambda item: item["start"])
    if not events:
        return {}

    current_index = 0
    for index, event in enumerate(events):
        if event["start"] <= now:
            current_index = index
        else:
            break
    current = events[current_index]
    next_event = events[current_index + 1] if current_index + 1 < len(events) else None
    return {
        "brazil-tv-camara": {
            "current_event_title": current["title"],
            "current_event_time": local_time_label(current["start"]),
            "next_event_title": next_event["title"] if next_event else None,
            "next_event_time": local_time_label(next_event["start"]) if next_event else None,
            "confidence": "official_weekly_schedule",
        }
    }


def _active_tab_html(html: str) -> str | None:
    match = re.search(
        r'<div[^>]*class="[^"]*\btab-pane\b[^"]*\bactive\b[^"]*"[^>]*>'
        r"([\s\S]*?)(?=<div[^>]*class=\"[^\"]*\btab-pane\b|</div>\s*</div>\s*</div>)",
        html,
        flags=re.IGNORECASE,
    )
    return match.group(1) if match else None
