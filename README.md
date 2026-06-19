# Parliaments

Parliaments is a documentation and data project for public parliamentary
video sources. It records the stream endpoints, official pages, schedule/EPG
surfaces, scraper notes, and rights/permission evidence found while researching
open parliamentary video access.

The repository is intended to be a public, inspectable catalogue and research
record.

## What Is Here

- `data/channels.json`: canonical source catalogue.
- `parliament_streams/scrapers/`: Python parsers for the schedule/EPG sources
  already understood by the prototype.
- `docs/sources-and-provenance.md`: source ownership, reuse, and provenance
  boundaries.
- `docs/source-rights-and-permissions.md`: source-by-source permission and
  rights evidence.
- `research.md`: working research log for stream discovery and source notes.
- `plan.md`: current roadmap for the documentation/data project.
- `tests/`: data-contract and scraper-registry tests.

## Catalogue Scope

The catalogue includes:

- direct HLS endpoints discovered from official pages, official APIs, or
  official-vendor player infrastructure;
- official YouTube/link-out sources where direct stream reuse is not
  appropriate;
- one legacy DASH research candidate kept for provenance;
- official pages used for source attribution and validation;
- schedule/EPG scrape surfaces for CPAC, Quebec, Ontario, New Zealand, and
  Brazil;
- permission status, evidence links, and reuse recommendations for every
  channel entry.

This is not an endorsed global directory and not a rebroadcast service. Public
availability does not automatically mean permission to redistribute, embed, or
play a stream natively in another product.

## Python Scrapers

The scraper modules are small standard-library parsers. They are meant to
document and reproduce the parsing logic that used to live in Swift schedule
adapters.

Current scraper ids:

- `cpac`
- `quebec-webdiffusion`
- `new-zealand-parliament`
- `ontario-calendar`
- `brazil-tv-camara`

They parse supplied HTML/JSON strings. Network fetching is deliberately not
hidden inside the parsers so validation runs can record exactly what was
downloaded, when, and from which official endpoint.

Parse a saved response with the scraper CLI:

```sh
python3 -m parliament_streams.scrapers cpac /path/to/cpac-schedule.html
```

Quebec uses two official JSON endpoints, so pass the live response first and
the upcoming response second:

```sh
python3 -m parliament_streams.scrapers quebec-webdiffusion live.json upcoming.json
```

The command prints parsed channel metadata as JSON. It does not fetch network
resources itself.

## Verify

Run the local verification pass:

```sh
make verify
```

This runs JSON validation, Ruff linting, Python import/compile checks, and the
unit tests.

Format Python sources with:

```sh
make format
```

## Rights And Reuse

The repository code and original documentation are covered by the repository
license. External stream URLs, official pages, schedule data, video content,
marks, watermarks, screenshots, and YouTube metadata belong to their respective
sources and may be governed by separate terms.

Before using a source outside research or advocacy:

1. Review its official page.
2. Review its terms and attribution requirements.
3. Prefer documented official embeds or APIs.
4. Preserve visible attribution.
5. Avoid implying endorsement.
6. Seek written permission where the status is pending or ambiguous.

See `docs/sources-and-provenance.md` and
`docs/source-rights-and-permissions.md` for the current evidence.

## Why This Exists

Public parliamentary video is often available, but not always in predictable,
machine-readable, app-friendly forms. This project documents what was found and
where openness could improve: stable HLS or documented embeds, JSON schedules,
event IDs, now/next signals, timezone data, chamber labels, captions/audio
metadata, plain-language terms, browser compatibility, and clear off-air
signals.
