"""Parsers for Quebec National Assembly live and upcoming webdiffusion endpoints."""

from __future__ import annotations

import json
import re
from datetime import UTC, datetime

from .common import checked_label, clean_html

SOURCE = {
    "id": "quebec-webdiffusion",
    "channel_ids": [f"quebec-canal{i:02d}" for i in range(1, 15)],
    "urls": [
        "https://www.assnat.qc.ca/Gabarits/RefonteVA_Accueil.aspx/ObtenirListeEnDirect",
        "https://www.assnat.qc.ca/Gabarits/RefonteVA_Accueil.aspx/ObtenirListeAVenir",
    ],
    "method": "POST",
    "body": {"codeLangue": "fr"},
    "notes": "Official ASP.NET JSON endpoints used by the live webdiffusion page.",
}


def parse(live_json: str, upcoming_json: str = '{"d":[]}', now: datetime | None = None) -> dict:
    now = now or datetime.now(UTC)
    live_items = json.loads(live_json).get("d", [])
    upcoming_items = json.loads(upcoming_json).get("d", [])
    next_item = upcoming_items[0] if upcoming_items else None
    next_title = clean_html(next_item.get("Titre", "")) if next_item else None
    next_time = None
    if next_item:
        next_time = (
            f"{clean_html(next_item.get('Date', ''))}, {clean_html(next_item.get('Heure', ''))}"
        )

    fallback = {
        channel_id: {
            "current_event_title": "No live webcast listed",
            "current_event_time": checked_label(now),
            "next_event_title": "Next listed Quebec webcast" if next_title else None,
            "next_event_time": next_time,
            "confidence": "official_live_list",
        }
        for channel_id in SOURCE["channel_ids"]
    }

    for item in live_items:
        if item.get("DiffusionDisponible") is False:
            continue
        match = re.search(r"canal(\d{2})", item.get("UrlSignal", ""))
        if not match:
            continue
        channel_id = f"quebec-canal{match.group(1)}"
        fallback[channel_id] = {
            "current_event_title": clean_html(item.get("Titre", "")),
            "current_event_time": "Live now",
            "next_event_title": next_title,
            "next_event_time": next_time,
            "confidence": "official_live_list",
        }

    return fallback
