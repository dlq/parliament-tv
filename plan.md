# Parliaments Plan

This is the live product and engineering plan for Parliaments. It should describe the current app, what is done, and what remains. Detailed source validation, terms notes, candidate discovery, schedule-surface research, and comparable UI notes belong in `research.md`.

## Current Goal

Build a focused Apple-platform app for surfing curated public parliamentary video sources with:

- fast native playback for direct HLS sources;
- clear separation between native streams and YouTube/link-out sources;
- visible source provenance and legal/terms caution;
- useful now/next metadata where official schedule sources are available;
- a calm TV-like interface that works on tvOS, iPhone, iPad, and macOS.

This is not a complete global directory and not a rebroadcast service. It is a prototype that demonstrates the usefulness of predictable public streams, schedule metadata, captions/audio metadata, and clear official-source links.

## Current State

### App

- Done: one SwiftUI/Xcode project targets iPhone, iPad, macOS, and Apple TV.
- Done: bundle ID is `ca.dlq.parliaments`.
- Done: iOS, macOS, and tvOS builds have reached TestFlight upload.
- Done: tvOS archive support uses a native `App Icon & Top Shelf Image` brand asset collection with generated Info.plist metadata.
- Done: app icon assets are present for iOS, macOS, and tvOS packaging.

### Playback

- Done: native AVPlayer/AVKit playback for direct HLS channels.
- Done: macOS-only experimental DASH path for the Mongolia Parliament TV candidate.
- Done: non-native sources use source-detail/link-out surfaces instead of pretending to be native channels.
- Done: macOS has an experimental in-app web view path for selected external pages.
- Remaining: improve playback diagnostics using AVFoundation access/error logs, audio/caption discovery, and consistent failure states.

### Catalogue

The catalogue currently lives as typed Swift seed data in `App/ChannelCatalog.swift`. That is intentional while source validation, schedule adapters, and model fields are still changing quickly.

Current catalogue shape:

- 36 native non-macOS channels from direct HLS seed data.
- 37 native channels on macOS, including the experimental Mongolia DASH source.
- 4 external YouTube/link-out sources with bundled preview captures.
- Groups: `Pinned`, `National`, `Regions`, and `YouTube`.

Current source groups:

- National direct HLS: CPAC, New Zealand, Brazil, Denmark, Netherlands, Spain, France, Portugal, Greece, Luxembourg, Italy Senate, India Sansad TV 1/2, Thailand, Slovakia, and macOS-only Mongolia DASH.
- Regions: Quebec canal01-canal14, Ontario House/committee/media streams, and Nunavut.
- YouTube/link-out: UK Parliament, Australia Parliament Live, Taiwan Parliamentary TV, and Costa Rica Assembly.

Remaining catalogue work:

- Add logo/brand assets only when provenance and reuse status are clear.
- Keep official text labels primary; logos are trust cues, not accessible names.
- Revisit JSON/YAML data once second-ring sources, logo provenance, and schedule-adapter mappings stabilize.
- Keep a future public catalogue repository separate from this app until the schema is stable.

### Program Metadata

Done schedule adapters:

- CPAC daily schedule.
- Quebec live/upcoming webdiffusion metadata.
- New Zealand House next-meeting/calendar metadata.
- Ontario calendar metadata.
- Brazil TV Camara weekly schedule metadata.

Current metadata behavior:

- Use source-specific adapters, not a universal EPG parser.
- Show now/next when a source adapter can produce it.
- Show signal state or `Schedule unavailable` when no schedule source is wired.
- Treat missing guide data as normal, not as a playback failure.

Remaining schedule work:

1. UK Parliamentlive Guide adapter: day guide, room/chamber labels, event details, agenda items.
2. European Parliament webstreaming adapter: extract official Multimedia Centre REST calls before implementation.
3. YouTube live/current adapter for official YouTube fallbacks.
4. Portugal ARTV agenda adapter after session/export behavior is understood.
5. Spain Congreso/Canal Parlamento programming adapter.
6. Later: Netherlands, France, Denmark, Greece, Luxembourg, Mauritius, Italy, India, Thailand, Slovakia, Nunavut, and other second-ring sources as structured official endpoints are found.

## Product Decisions

### Apple-first

The app is Apple-first because the core experience is channel surfing: full-screen video, remote-first navigation, fast channel changes, and a living-room context. tvOS remains the product driver, with iPhone, iPad, and macOS sharing the same catalogue and playback model.

Implications:

- Prefer AVPlayer-compatible HLS.
- Treat YouTube and official web players as second-class but useful.
- Do not extract YouTube HLS manifests.
- Do not proxy or rehost video segments.
- Preserve a portable data model so a web app or separate catalogue can exist later.

### Source Quality

Every channel should expose:

- source type;
- official source URL;
- source owner/provenance;
- terms/legal review status;
- availability model;
- metadata confidence;
- audio and caption language where known.

Default rules:

- Prefer official source pages, official player infrastructure, or official YouTube channels.
- Avoid third-party relays unless there is no official alternative and the source is clearly labelled.
- Do not strip watermarks or official overlays.
- Keep CPAC cautious until permission/reuse is reviewed.
- Keep Quebec and Ontario as non-commercial pending-review local-priority sources.
- Treat New Zealand and Brazil as the strongest current terms candidates, with conditions.

### UI

Current direction:

- Full-screen video is the primary surface.
- The guide is an overlay, not a separate home screen.
- Channel up/down and swipe navigation are more important than search in the prototype.
- The UI should feel like a public-service TV tuner, not an entertainment storefront.
- Source labels should be quiet but visible.
- Missing schedules and off-air feeds should look intentional.

Done:

- Guide drawer and rail.
- Platform-aware previous/next/guide overlays.
- Pinned channels and channel groups.
- Pin/unpin behavior.
- Phone landscape compact layout.
- macOS menu/keyboard commands.
- tvOS remote navigation and focus-aware guide behavior.
- External-source cards with bundled 16:9 preview captures.

Remaining UI work:

- Add UI smoke tests for opening the guide, changing channels, hiding the guide, pinning, and compact phone landscape.
- Improve shared loading/off-air/error states across HLS, DASH, YouTube/link-out, and schedule-poor channels.
- Follow up on macOS AVKit floating-controls icon overlap.
- Consider lazy HLS frame previews in guide cards for visible/focused native HLS cards only.
- Periodically refresh bundled 16:9 external-source captures and track capture date/source URL.

## Engineering State

### Structure

Done:

- `ContentView` is primarily orchestration/state.
- `ProgramDrawer`, `ChannelGuideRail`, `ChannelGuide`, `ChannelActionOverlays`, `ChannelNavigationModifiers`, `PlayerSurface`, `PlatformPlayers`, `LinkOutSurface`, `ChannelCollections`, and `MacPlayerWindowConfigurator` split the UI into focused pieces.
- `Models.swift` holds typed source, legal, availability, metadata, and confidence enums.
- Schedule adapters are separate files with unit coverage.
- Localized strings use `App/Localizable.xcstrings` through the `L10n` helper.

Current guidance:

- Keep extracting only when a file starts carrying multiple responsibilities again.
- Avoid abstraction for its own sake.
- Introduce a persistence boundary only when recent channels, custom pins, validation history, or user channel overrides outgrow `AppStorage`.

### Verification

Done:

- `make format` uses Xcode's bundled `swift-format`.
- `make format-check` runs `swift-format` lint.
- `make test` runs macOS tests.
- `make verify` runs whitespace checks, formatting lint, macOS tests, iPhone simulator build, iPad simulator build, and tvOS simulator build.
- GitHub Actions runs the conservative public baseline: whitespace checks, `swift-format` lint, and macOS tests.

Remaining:

- Expand CI to include iPhone, iPad, and tvOS simulator builds once runner destinations are stable.
- Add UI smoke tests for guide/channel behavior.
- Add accessibility checks for VoiceOver labels, focus order, Dynamic Type, contrast, and remote/touch/keyboard parity.
- Add structured logging for playback failures, metadata refresh failures, schedule parser drift, channel switching, and external-source launches.

### Localization

Done:

- App-shell localization is scaffolded with `Localizable.xcstrings`.
- First-pass translations exist for shared labels, menus, guide controls, player status text, and external-source surfaces.

Current stream-language coverage:

- English, French, Portuguese, Danish, Dutch, Spanish, Greek, Luxembourgish, Italian, Hindi, Thai, Slovak, Mongolian, Inuktitut, Simplified Chinese, Traditional Chinese, and Maori.

Remaining:

- Treat translations as review-needed, especially lower-resource locales and source-specific terms.
- Continue source metadata handling: channel names, schedule titles, audio labels, captions, scripts, accents, sorting, search, and fallback text.
- Test layout with diacritics/macrons, Greek, Devanagari, Thai, Cyrillic/Mongolian-related text, Inuktitut syllabics where available, and Chinese scripts.

## Release Readiness

Done:

- Public GitHub repository exists.
- `README.md`, BSD 3-Clause `LICENSE`, `CONTRIBUTING.md`, `PRIVACY.md`, `SECURITY.md`, and source/provenance docs are present.
- Fresh macOS, iPhone, iPad, and tvOS screenshots are in `docs/screenshots/`.
- `TESTFLIGHT.md` tracks beta description, review notes, privacy summary, and local release checks.
- iOS, macOS, and tvOS archive uploads have been exercised.
- tvOS packaging uses a native `App Icon & Top Shelf Image` brand asset collection for the app icon and Top Shelf wide image.

Remaining:

- Keep App Store Connect metadata current for each platform.
- Fill privacy nutrition answers from `PRIVACY.md`.
- Keep TestFlight review notes clear that the app is unofficial and uses public official sources.
- Review platform-specific screenshots and preview assets before any public App Store submission.
- Evaluate Xcode Cloud after TestFlight flow stabilizes. Use it only if it adds value beyond GitHub Actions plus local `make verify`.

## Future Work

### Curated Second Ring

Do not open a broad sub-national catalogue yet. Add curated candidates only when source ownership, terms, and playback behavior are understood.

Likely order:

1. Canada expansion: verify Nunavut official page/terms/schedule, then BC, Alberta, Saskatchewan, and Manitoba.
2. UK devolved parliaments: Scotland, Wales/Senedd, and Northern Ireland as official-player/schedule cards.
3. Australia states: NSW, Queensland, WA, and Victoria as official-player/schedule cards.
4. Germany pilot: Baden-Wurttemberg and NRW for possible direct HLS extraction.
5. Supra-national: PACE and Nordic Council as event-based official-player cards.

Only direct HLS or AVPlayer-compatible streams should enter the native surf rail. Official-player-only sources should remain metadata/link-out cards until an Apple-compatible playback path is validated.

### Privacy-preserving Popularity

Plan before building:

- Make viewing analytics opt-in.
- Do not store accounts, raw IPs, precise GPS, or per-user viewing histories.
- Derive approximate location only long enough to bucket it, then discard raw addresses.
- Store only coarse aggregate buckets such as channel ID, country/region/large-metro bucket, hour-of-day, day-of-week, month/season, and count.
- Apply minimum contribution thresholds before showing popularity data.
- Expose results as discovery affordances such as `Popular`, `Popular now`, or broad regional badges.
- Evaluate CloudKit as one option: private database for synced preferences, public database for app-wide aggregate popularity records, and CloudKit Console telemetry/logs. CloudKit does not replace the privacy design.

### Apple Frameworks To Revisit

- `AVFoundation` / `AVKit`: access/error logs, media-selection groups, timed metadata, captions, audio-language discovery, PiP, and better live-state handling.
- `NaturalLanguage`: lightweight language detection and title cleanup.
- `Translation`: optional translation of trusted schedule metadata.
- `Vision`: OCR for bundled external-source screenshots or limited frame diagnostics.
- `Speech`: live transcription/caption experiments only after legal, cost, and UX review.
- `AppIntents`: shortcuts for opening pinned channels or groups.
- `SwiftData`: pins, recents, overrides, and validation history if `AppStorage` becomes too small.
- `BackgroundTasks`: local refresh where platform rules allow; prefer server-side validation for durable monitoring.
- `GroupActivities` / SharePlay: synchronized watching as later research.
- Foundation Models: optional metadata extraction and summarization on supported platforms, not tvOS-first MVP infrastructure.

### Openness and Standards Advocacy

After the app is stable enough to demonstrate the model, use it as evidence for light advocacy with legislatures and broadcast vendors.

Advocate for:

- stable official HLS streams or documented official embeds;
- JSON schedule endpoints with stable event IDs;
- now/next or live-state endpoints;
- source-local timezone plus UTC start/end timestamps;
- chamber, room, committee, legislature, and jurisdiction labels;
- caption, sign-language, and audio-language metadata;
- plain-language terms for non-commercial public-access apps;
- Apple-platform/browser playback compatibility, including CORS where applicable;
- off-air/status signals for sitting-only streams.

Useful future artifact:

- A benchmark matrix showing direct HLS, official embeds, schedule APIs, now/next metadata, captions/accessibility metadata, terms clarity, and Apple-platform compatibility by legislature.

## Biggest Risks

- Terms of use and rebroadcast/embedding permission.
- Stream URLs and official pages changing without notice.
- Schedule adapters drifting when official sites change.
- Sitting-only streams being misclassified as broken.
- YouTube live IDs, embeds, ads, and availability changing.
- tvOS limits for YouTube, web iframes, and official web-only players.
- UI density across phone landscape, iPad, macOS, and tvOS.
- Scope creep from global and sub-national coverage.

## Current Recommendation

Continue with the focused Apple-first prototype. The app has proven the core surfability model. The next work should emphasize release polish, schedule reliability, source/rights clarity, accessibility, and a small number of high-value source integrations rather than broad catalogue expansion.
