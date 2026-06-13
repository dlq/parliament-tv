# Sources and Provenance

This project is a public-interest prototype for exploring parliamentary live video access. It is not an official source for any legislature, broadcaster, streaming vendor, or video platform.

## Code License Scope

The repository license covers the project code and documentation written for this repository.

It does not grant rights to:

- parliamentary broadcast video;
- official logos, coats of arms, seals, watermarks, or marks;
- official website screenshots;
- third-party player assets;
- stream URLs or schedule data owned or operated by external bodies;
- YouTube pages, thumbnails, metadata, or embedded player behavior.

## Catalogue Entries

The current catalogue is Swift seed data in `App/ChannelCatalog.swift`. It contains a curated set of public official pages, official-vendor HLS candidates, direct HLS/DASH experiments, and official YouTube/link-out sources.

Each source should be treated as provisional unless its own official page and terms clearly support the intended use. Some direct URLs are discovered through official pages, official APIs, or official player infrastructure, but that does not automatically mean they are appropriate for all redistribution or embedding contexts.

## Legal and Terms Posture

The app uses conservative labels such as personal-use pending review, noncommercial pending review, explicit reuse with conditions, and embed-only. These are implementation notes, not legal advice.

Before using this catalogue outside local testing or advocacy demos:

- review the official source page;
- review terms of use and attribution requirements;
- prefer documented official embeds or APIs where available;
- preserve source links and visible attribution;
- avoid implying endorsement by any legislature or broadcaster.

## Preview Images and Design Assets

Bundled external-source preview images are page captures used to make link-out cards understandable in the prototype. Refresh them periodically and track:

- source URL;
- capture date;
- whether consent, sign-in, cookie, or geolocation UI was visible;
- whether the capture includes official marks or third-party platform UI.

README screenshots under `docs/screenshots/` are development captures of the running app. They can include live public broadcast frames, watermarks, captions, and official marks from the underlying source. They are included to document the prototype UI, not to grant rights in the underlying content.

Design concept exploration assets are intentionally excluded from the public repository baseline. The tracked app icon assets are project assets, not official legislative symbols.

## Research Log

`research.md` is a working log. It contains validated findings, failed checks, speculative candidates, external references, and older observations that can become stale. It should not be treated as a polished public registry.

The file is intended to be public, but it should still be treated as research evidence rather than permission guidance. Revalidate URLs, playback behavior, schedules, and terms before relying on an entry.

The long-term advocacy direction may be a separate open parliamentary streams catalogue with explicit schema, validation history, provenance, and terms fields. That is distinct from the app's current prototype catalogue.
