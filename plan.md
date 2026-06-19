# Parliaments Plan

This is the live plan for Parliaments as a documentation and data project. The
current repository should be optimized for public research, source provenance,
machine-readable catalogue data, and reproducible schedule-scraper notes.

## Current Goal

Maintain a public informational repository that documents:

- direct HLS parliamentary video endpoints found from official or
  official-vendor sources;
- official YouTube and official-page alternatives where direct stream reuse is
  not appropriate;
- schedule/EPG surfaces and Python parsers for sources already understood;
- permission, terms, and redistribution evidence for every source;
- research notes that explain how each source was discovered and where the
  openness gaps remain.

This is not a rebroadcast service and not an endorsed source directory.

## Current State

Done:

- `data/channels.json` is the canonical catalogue.
- The catalogue records HLS, YouTube, official-page, and legacy DASH research
  entries with jurisdiction, language, attribution, availability, metadata
  level, EPG sources, and permission status.
- Python scraper modules exist for CPAC, Quebec webdiffusion, Ontario calendar,
  New Zealand calendar, and Brazil TV Camara weekly schedule sources.
- `docs/source-rights-and-permissions.md` records source-by-source rights evidence
  and recommendations.
- `docs/sources-and-provenance.md` explains repository license scope and
  external-source limitations.
- `research.md` remains the working evidence log for stream discovery.
- CI and `make verify` now validate JSON, compile Python modules, and run the
  contract tests.

Retired from the active project:

- SwiftUI app source.
- Xcode project files.
- Apple-platform build/test/release workflow.
- App-release checklist.

## Catalogue Work

Near-term:

1. Split repeated permission summaries into a normalized `data/permissions.json`
   only if the inline channel entries become hard to review.
2. Add explicit schemas for stream/source entries, permission evidence, EPG
   scrape surfaces, validation history, and generated reports.
3. Add validation-history fields for endpoint checks, including checked date,
   HTTP status, content type, and validator environment.
4. Distinguish first-party, official-vendor, platform, and third-party relay
   endpoints explicitly.
5. Add a source freshness field for URLs that are likely to drift.
6. Make the schema distinguish source discovery from permission status, because
   a stream can be technically reachable but unsuitable for redistribution.

Later:

1. Build a small static catalogue view from `data/channels.json`.
2. Publish periodic validation reports without republishing external content.
3. Add CSV exports for source, endpoint, permission, and EPG inventories.

## Scraper Work

The Python scrapers should stay narrow and auditable. They parse supplied
HTML/JSON; network fetches should be explicit in future collection scripts so
the repo can record what was fetched and when.

Near-term:

1. Add fixture-based parser tests for each current scraper.
2. Add a `scripts/fetch_epg.py` command that downloads official schedule pages
   into timestamped local artifacts outside the tracked baseline.
3. Add parser result examples under `examples/` once fixtures exist.
4. Document required request headers and POST bodies beside each scraper.

Candidate future scrapers:

1. UK Parliamentlive guide/day/info surfaces.
2. European Parliament Multimedia Centre REST calls.
3. Portugal ARTV agenda.
4. Spain Congreso/Canal Parlamento programming.
5. Netherlands, France, Denmark, Greece, Luxembourg, Mauritius, Italy, India,
   Thailand, Slovakia, Nunavut, and other second-ring sources when structured
   official endpoints are found.

## Rights And Permission Work

Near-term:

1. Keep `docs/source-rights-and-permissions.md` as the evidence-backed matrix for
   source terms and permission status.
2. Add a short public-facing `docs/rights-summary.md` if the detailed matrix
   becomes too long for readers who only need the current posture.
3. Record written permission requests and responses as summarized evidence, not
   raw private correspondence.
4. Keep CPAC marked link-out/pending unless written consent is obtained.
5. Keep YouTube sources link-out or compliant-embed only; do not extract
   YouTube manifests.

## Research And Advocacy

The project should help show what makes parliamentary video reusable and
discoverable without overclaiming rights.

Useful advocacy asks:

- stable HLS or documented embed routes;
- JSON schedule APIs;
- stable event IDs;
- now/next signals;
- timezone data;
- chamber and room labels;
- captions and audio-language metadata;
- plain-language reuse terms;
- CORS/browser compatibility;
- explicit off-air and no-signal status.

Detailed discovery history belongs in `research.md`; action-oriented next steps
belong here.
