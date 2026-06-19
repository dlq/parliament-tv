# Contributing

This project is early and curated. Small, evidence-backed changes are easiest to
review.

Use the GitHub issue templates for source corrections, endpoint validation
problems, and schedule metadata issues. If the report is sensitive, follow
[SECURITY.md](SECURITY.md) instead of opening a public issue.

## Source Or Stream Corrections

For channel/source changes, include:

- official legislature or broadcaster page URL;
- stream URL, official embed URL, official YouTube URL, or official player URL;
- source type: HLS, DASH, YouTube, official player, official page, or unknown;
- validation date and region;
- status code, content type, and observed player behavior if tested;
- terms, permission, or attribution notes;
- schedule/EPG endpoint, if one exists;
- known caveats such as geofencing, login prompts, off-air behavior, or
  event-only availability.

Avoid adding community playlist URLs unless they can be traced back to an
official page, official API, official embed, or official streaming vendor path.

## Data And Scraper Changes

Before opening a pull request, run:

```sh
make verify
```

`make verify` validates the JSON catalogue, runs Ruff linting, compiles Python
modules, and runs the data/scraper contract tests.

Python scrapers should parse supplied HTML/JSON strings. Do not hide network
fetches inside parser functions; fetch scripts should record where data came
from and when it was retrieved.

To test a parser manually, save the official response to disk and run:

```sh
python3 -m parliament_streams.scrapers <scraper-id> <response-file>
```

## Research Notes

`research.md` is a working log. Prefer moving polished, reusable source guidance
into `docs/` once a finding is stable.
