# Contributing

This project is early and curated. Small, evidence-backed changes are easiest to review.

Use the GitHub issue templates for playback bugs, source corrections, schedule metadata issues, and platform/UI problems. If the report is sensitive, follow [SECURITY.md](SECURITY.md) instead of opening a public issue.

## Source or Stream Corrections

For channel/source changes, include:

- official legislature or broadcaster page URL;
- stream URL or official embed URL, if applicable;
- source type: HLS, DASH, YouTube, official player, or unknown;
- platform compatibility observed: AVPlayer, browser, YouTube app, or other;
- validation date and region;
- terms or attribution notes;
- schedule/EPG endpoint, if one exists;
- known caveats such as geofencing, login prompts, off-air behavior, or event-only availability.

Avoid adding community playlist URLs unless they can be traced back to an official page, official API, official embed, or official streaming vendor path.

## Code Changes

Before opening a pull request, run:

```sh
make format-check
make test
```

For larger UI or playback changes, also run:

```sh
make verify
```

`make verify` depends on local simulator names, so it may need adjustment if your Xcode installation has different simulator devices.

The public GitHub Actions workflow currently runs whitespace checks, `swift-format` lint, and macOS tests. The broader iPhone, iPad, and tvOS simulator build pass is still local-only through `make verify`.

## Research Notes

`research.md` is a working log. Prefer moving polished, reusable source guidance into `docs/` once a finding is stable.
