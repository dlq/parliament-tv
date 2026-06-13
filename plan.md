# Parliamentary Channel Surfer MVP Plan

## Goal

Build a focused app for flipping between curated, public parliamentary video sources with clear source quality, live/off-air state, and whatever program metadata is available.

The MVP is not a complete global parliament directory. It is a proof that the channel-surfing experience works across:

- direct HLS streams
- official link-out/player fallbacks
- selected YouTube sources where Apple-platform integration is acceptable
- schedule-aware and schedule-poor channels

## Platform Strategy

Target a universal Apple app first, with tvOS as the product driver.

This is a deliberate product constraint. A web app would maximize access and simplify iframe/YouTube integration, but the core experience is channel surfing: full-screen video, remote-first controls, quick channel switching, and a living-room context. That fits tvOS well.

Apple-first implications:

- Prioritize direct HLS because AVPlayer supports it natively across iOS, iPadOS, macOS, and tvOS.
- Treat YouTube and official iframe-only sources as secondary unless there is a supported Apple-platform integration path.
- Prefer official link-out or metadata-only cards for sources that cannot be played cleanly in-app.
- Keep the data model web-compatible so a web app can be added later without redoing the catalogue.
- Design controls around the Siri Remote first, then adapt to touch/keyboard.

Platform order:

1. tvOS-first universal Apple app.
2. iPad/macOS companion layout using the same catalogue and playback core.
3. Web app later for broader public access and iframe-heavy sources.

## Product Scope

### In scope

- A curated channel list.
- Native playback for direct HLS where technically and legally reasonable.
- Link-out or metadata fallback for official platforms where raw streams are not appropriate.
- YouTube support only where the Apple-platform implementation is acceptable.
- Clear labels for source owner and legal/source quality.
- Live/off-air state.
- Basic "now/next" or upcoming metadata where available.
- Manual channel metadata file to start.
- Automated stream validation for direct HLS/DASH candidates.

### Out of scope

- Comprehensive global coverage.
- Broad sub-national crawling.
- Redistributing or proxying streams.
- Extracting YouTube HLS manifests.
- Recording, clipping, editing, or archiving video.
- User accounts, recommendations, comments, or social features.
- Full cable-TV-style EPG completeness.
- Perfect parity with web-only iframe sources on tvOS.

## Curated MVP Lineup

### Local priority exceptions

These are included because they are local-priority sources and already validated.

| Channel | Source type | Metadata target | Notes |
| --- | --- | --- | --- |
| Quebec National Assembly canal05/canal06/canal14 seed set | Direct HLS | current event from live-list API | Keep all 14 known channels in data, but surface active channels first. |
| Ontario Legislative Assembly House EN | Direct HLS | current/next from OLA calendar | Add committee/media channels after playback spike. |
| Nunavut Legislative Assembly TV | Direct HLS candidate | signal state only | Added as a low-confidence Regions channel; official page, schedule, and terms review still required. |

### Core national/supranational set

| Channel | Source type | Metadata target | Notes |
| --- | --- | --- | --- |
| CPAC | Direct HLS | daily schedule | Technically strong; legal label should be cautious. |
| New Zealand Parliament TV | Direct HLS | sitting calendar | Strong legal and technical candidate. |
| France National Assembly | Direct HLS | official video portal schedule if available | Direct HLS validated. |
| Brazil TV Camara | Direct HLS | official schedule if available | Strong legal signal for legislative activity. |
| Denmark Folketinget | Direct HLS | official schedule if available | Good Apple-first candidate because HLS validated. |
| Netherlands Tweede Kamer | Direct HLS | official schedule if available | Good Apple-first candidate because HLS validated. |
| European Parliament | Official player/link-out initially | daily schedule | Important source, but likely not core in-app playback until a clean Apple-compatible stream path is confirmed. |
| UK Parliament | Official page/link-out or YouTube | daily schedule | Important source, but Red Bee/player constraints make it secondary for tvOS v1. |
| Australia Parliament | YouTube embed | current/scheduled live | Official `@AUSParliamentLive`. |
| Taiwan Parliamentary TV | YouTube embed | current/scheduled live | Official site already embeds YouTube channels/playlists. |

### Optional stretch channels

Add only after the core playback model works.

- Denmark Folketinget
- Netherlands Tweede Kamer
- Portugal ARTV
- Spain Congreso
- Greece Hellenic Parliament TV
- Luxembourg Chamber TV
- Mauritius Parliament TV
- Italy Senate
- India Sansad TV
- Thailand Parliament TV

## Channel Data Model

Start with a static JSON/YAML file. A database is unnecessary until the validator and UI prove useful.

```text
id
name
short_name
jurisdiction_level: national | subnational | supranational
country_or_region
legislature
language
source_type: direct_hls | direct_dash | official_embed | official_page | youtube_embed
source_owner: first_party_legislature | official_vendor | official_public_broadcaster | official_youtube | third_party_relay | community_playlist
display_mode: native_player | iframe | youtube | link_out
playback_url
official_url
schedule_url
terms_url
attribution_text
logo_asset_name
logo_url
brand_color
logo_rights_status: unknown | official_mark | explicit_reuse_allowed | attribution_required | permission_required | avoid
legal_review_status: not_reviewed | personal_use_only | noncommercial_with_attribution | explicit_reuse_allowed | embed_only | link_only | permission_required | avoid
technical_status
availability: 24_7 | sitting_only | event_based | unknown
metadata_level: none | signal_state_only | current_event | current_and_next_event | daily_schedule | full_epg
requires_user_gesture
supports_captions
audio_languages
caption_languages
last_validated_at
last_browser_playback_check_at
last_legal_review_at
```

## Program Metadata Model

Do not require a universal EPG. Use the best available metadata per source.

```text
channel_id
metadata_source_type: official_calendar | official_live_api | official_schedule_page | youtube_api | stream_probe | manual
current_event_title
current_event_start
current_event_end
next_event_title
next_event_start
next_event_end
timezone
confidence: high | medium | low
last_checked_at
```

Metadata levels:

```text
none
signal_state_only
current_event
current_and_next_event
daily_schedule
full_epg
```

Initial targets:

- CPAC: `daily_schedule`
- Quebec: `current_event`
- Ontario: `current_and_next_event`
- UK Parliament: `daily_schedule`
- European Parliament: `daily_schedule`
- New Zealand: `current_and_next_event`
- YouTube channels: `current_event` or `current_and_next_event`
- Raw HLS without schedule: `signal_state_only`

## Architecture

### Apple App

Core views:

- Channel surfer/player view.
- Channel rail/list.
- Current/next metadata panel.
- Source quality/details panel.
- Off-air/error state.

Player modes:

- Native HLS/DASH where AVPlayer supports the source.
- Official link-out or source detail card for player-only web sources.
- YouTube handling as a second-class mode unless a stable Apple-platform player path is chosen.

tvOS interaction:

- Siri Remote next/previous channel.
- Play/pause and swipe/click navigation.
- Minimal overlays that dismiss quickly.
- Large, legible now/next and source labels.
- Clear off-air/upcoming states.

Shared Apple code should keep playback, catalogue parsing, validation results, and metadata adapters reusable across tvOS, iOS, iPadOS, and macOS.

### Future Web App

The web app remains valuable later because it can handle:

- iframe-heavy sources
- YouTube embeds more naturally
- broader public access
- easier sharing and testing

Do not let the web target shape the first playback architecture. Keep the data model portable, but optimize v1 for Apple-native playback.

### Backend or local service

Small API layer:

- Serve channel catalogue.
- Run validation probes.
- Normalize current/next metadata.
- Cache schedule pages/API responses.
- Avoid proxying video segments.

Possible endpoints:

```text
GET /api/channels
GET /api/channels/:id
GET /api/channels/:id/status
GET /api/channels/:id/program
POST /api/validate
```

## Validation

### Stream validator

For direct HLS/DASH:

- HTTP status.
- Content type.
- CORS headers with app origin.
- Master/media playlist shape.
- Variant count.
- Segment advancement over time.
- Segment-level CORS.
- Geo/block/error status.

Statuses:

```text
validated_playlist
validated_browser_playback
cors_ok
active_now
inactive_sitting_only
blocked
geo_blocked
broken
unknown
```

### Browser playback spike

Before building the full UI, prove Apple playback on:

- tvOS simulator or device with AVPlayer.
- iOS/iPadOS simulator with AVPlayer.
- macOS Catalyst or native macOS target if included.
- Link-out behavior for official-player-only sources.
- Optional YouTube path if a practical Apple-platform strategy is selected.

Spike channel set:

- CPAC
- Quebec canal05
- Ontario house-en
- New Zealand Parliament TV
- Brazil TV Camara
- Denmark or Netherlands direct HLS
- UK Parliament official page/link-out
- European Parliament official page/link-out
- Australia or Taiwan YouTube only if feasible on Apple platforms

Pass criteria:

- Direct HLS plays in the tvOS app with AVPlayer.
- Direct HLS plays in the iOS/iPadOS app with AVPlayer.
- Remote/channel controls feel natural on tvOS.
- YouTube/link-out channels do not block the core experience.
- Off-air/inactive streams do not look like app failures.
- Each channel displays source owner, terms status, and official link.

## Legal and Source Quality Rules

Every channel must show:

- Source owner.
- Official page.
- Terms status.
- Attribution if required.
- Logo/brand provenance when a logo is used.

Default rules:

- Prefer official source pages and supplied embed codes where available.
- Do not proxy or rehost streams.
- Do not strip watermarks.
- Do not extract YouTube HLS.
- Use official logos only when the source and reuse status are clear.
- Keep channel text labels primary; logos are trust/provenance cues, not a substitute for accessible names.
- Mark CPAC as `permission_required` or `personal_use_only` until reviewed.
- Mark Quebec/Ontario as `noncommercial_with_attribution`.
- Mark New Zealand and Brazil as high-confidence with conditions.
- Mark third-party relays as lower trust and hide them from default MVP unless there is no official alternative.

## UX Requirements

### Design References

Comparable apps and surfaces to study:

| Reference | Why it matters | Ideas to borrow |
| --- | --- | --- |
| [Channels: Whole Home DVR](https://apps.apple.com/us/app/channels-whole-home-dvr/id1405359767) | Closest conceptual match: live TV, Apple TV, guide data, favorites, DVR mental model. | Simple live-TV navigation, guide-first browsing, favorites, resume/continue patterns, family-friendly channel switching. |
| [IPTVX](https://apps.apple.com/us/app/iptvx/id1451470024) | Polished iOS/tvOS IPTV app with EPG grid, live zapping, on-player EPG, favorites, iCloud sync, and EPG search. | Fast live-channel switching, on-player metadata, favorites, search across program metadata, background catalogue refresh. |
| [iPlayTV](https://apps.apple.com/us/app/iplaytv-iptv-m3u-player/id1072226801) | Apple TV-only IPTV player focused on playlists, EPG, channel preview, favorites, frame-rate matching, and audio/subtitle tracks. | tvOS-first simplicity, channel preview, remote-friendly live-channel UX, audio/subtitle handling. |
| [TivEPG](https://tivepg.com/) | IPTV app presenting a Sky Glass-style horizontal EPG and Siri Remote-first navigation. | Horizontal timeline guide, category filters, rich now/next metadata, quick jumps from guide to playback. |
| [SWIPTV](https://apps.apple.com/us/app/swiptv-iptv-player/id1658538188) | Modern multi-device IPTV player with live EPG, previews, playlist refresh, multi-player, PiP, and metadata enhancements. | Fast refresh, instant previews, cross-device continuity, secondary player modes. |
| [HBO Max](https://www.macrumors.com/2025/12/04/apple-announces-2025-app-store-awards/) | Apple TV App of the Year in the 2025 App Store Awards. | Accessibility polish, large-screen navigation, high-quality content detail surfaces. |
| [tvOS 26 design direction](https://images.apple.com/uk/newsroom/2025/06/apple-tv-brings-a-beautiful-redesign-and-enhanced-home-entertainment-experience/) | Apple emphasizes keeping focus on what is playing with unobtrusive system UI. | Lightweight overlays, video-first layout, large readable type, restrained chrome. |
| Native Apple video player conventions | Recent criticism of custom Apple TV players shows users value platform affordances. | Prefer AVPlayer-native behavior where possible: remote scrubbing, captions, audio options, system accessibility, predictable playback controls. |

Secondary streaming comparables:

These are polish and interaction references, not the core product category. The app should borrow restraint, accessibility, trust cues, and live-event affordances from them, but avoid becoming a catalogue storefront.

| Reference | Why it matters | Ideas to borrow | Avoid |
| --- | --- | --- | --- |
| Apple TV app / Apple TV+ | Best native Apple-platform reference for system-integrated video, sports/live surfaces, and restrained playback chrome. | Elegant overlays, source aggregation, resume-last-context, multiview as a later live-event pattern, native accessibility expectations. | Storefront merchandising and promotional rows. |
| Netflix | Strong large-screen focus behavior, confident typography, and fast browsing mechanics. | Fast focus movement, readable TV-distance type, minimal controls while watching, strong selected-item clarity. | Autoplay preview culture and catalogue-density as the app's home model. |
| Crave / Max | Useful for premium large-screen hierarchy and content-detail polish. | Clean detail surfaces, captions/audio affordances, episode/event metadata presentation. | Entertainment-catalogue mental model and marketing-heavy rails. |
| CBC Gem | Closest public-service streamer tone among general services. | Institutional trust cues, live/event programming presentation, public broadcaster clarity, bilingual/accessibility expectations. | Generic streaming homepage structure. |
| YouTube TV | Strong live-TV reference with guide, live tab, customized channel order, and multiview. | Live guide behavior, channel pinning/custom ordering, live badges, multiview as a future committee/plenary monitoring mode. | Account/personalization complexity and recommendation-first home. |
| Fubo | Sports-first live-TV app with guide and progress context for jumping into live programming. | "What is on now / what is next / how far through is it" cues, quick live switching, persistent guide state. | Sports-betting or entertainment packaging. |
| Peacock / ESPN | Live-event streamers with many simultaneous event feeds. | Event collections, live-event hubs, multiview or synchronized second-screen ideas for busy sitting days. | Making multiview part of the MVP before single-stream surfing is excellent. |
| Pluto TV / Tubi live / Plex live TV | FAST-style linear streaming references. | Simple channel categories, quick channel-guide browsing, low-friction lean-back playback. | Ad-supported clutter, infinite low-value channels, and weak source provenance. |
| PBS / Kanopy | Public-interest and institutional-content references. | Calm tone, clear programme descriptions, accessibility, educational/public-good framing. | Library/catalogue browsing as the primary interaction. |

FAST/live-guide ideas to apply:

- Open directly into playback or the last-used guide position. FAST apps work because the user is never far from something playing.
- Use simple guide categories, not deep taxonomy: `Pinned`, `National`, `Local`, `Committees`, `Event-based`, `YouTube`, and official-player fallbacks.
- Preserve stable channel order and optionally show short channel numbers or codes. Parliament streams are often room/feed based, so stable positions reduce cognitive load.
- Let users hide noisy or inactive channels later; the first version can approximate this with pinned/local groups.
- Treat missing guide data as normal. Show `Schedule unavailable` or `Signal available, program unknown` instead of breaking the guide.
- Keep a visible official-source/provenance cue. FAST apps often blur source quality; this app should do the opposite.
- Avoid infinite channel count. A parliamentary surfer should feel curated and reliable, not like an endless free-TV catalogue.
- Consider a future `Monitoring` mode inspired by live-event/multiview apps for days with many simultaneous committees, but only after single-stream surfing and metadata are stable.

Design principles for this app:

- Full-screen video is the primary surface; metadata is an overlay.
- Channel up/down is more important than search in the first version.
- The app should feel like a calm public-service TV tuner, not a streaming-content storefront.
- Local priority channels should be pinned first: Quebec, Ontario, CPAC.
- Direct HLS channels should feel instant and native.
- Link-out, YouTube, and official-player-only channels should be visibly different from native channels.
- The guide should start as a horizontal now/next rail, not a dense cable-grid EPG.
- Off-air states should feel intentional: show next sitting or source status instead of an indefinite spinner.
- Source-quality labels should be visible but quiet: `Official HLS`, `Official vendor`, `Official YouTube`, `Link out`, `Schedule only`.
- Avoid decorative cards around video; the player is the canvas.
- Borrow polish from general streamers, but keep the start state as live playback or the guide, not a promotional home page.
- Metadata should answer: what am I watching, is it live, what is next, and can I trust this source?
- Public-service streamers are more relevant tonally than entertainment streamers because this app needs credibility more than excitement.

Prototype lessons from the first SwiftUI pass:

- The app's core "surfability" is proven when direct HLS channels play full-screen and channel changes work from the remote/keyboard.
- Chrome must get out of the way quickly; overlays should be temporary, translucent, and small enough not to compete with the video.
- Changing channel should resume playback automatically. The user should not have to press Play/Space after every channel change.
- tvOS focus styling needs to be owned by the app for the guide rail. Avoid default oversized focus underlays fighting the selected-channel highlight.
- Bottom guide cards need fixed text regions, truncation, and clipping so long legislature/channel names never resize or overflow the rail.
- A flat list of 20+ streams is already too much. The next UI pass should group or pin channels instead of only restyling the current rail.

Next UI pass:

- Add guide groups: `Pinned`, `National`, `Regions`, and `YouTube`.
- Keep local-priority pinned channels first: Quebec active channels, Ontario House, Nunavut candidate, and CPAC.
- Make native HLS channels the main surf rail; keep UK Parliament, European Parliament, Australia Parliament, and other official-player/YouTube sources in a separate source-detail/link-out surface until native Apple playback is validated.
- Evolve the bottom rail toward a now/next timeline, but do not build a dense cable-grid EPG for the MVP.
- Add a compact on-player mini guide with current channel, now/next metadata, source quality, language/captions, and official source.
- Use clearer live-state labels: `Live`, `Off air`, `Next sitting`, `Schedule unavailable`, and `Signal available, program unknown`.

Channel card should show:

```text
Logo or fallback monogram
Name
Jurisdiction
Live/off-air/unknown state
Now
Next
Source quality
Language/captions
Official source link
```

Player states:

- Loading
- Live
- Off air
- Upcoming
- Playback blocked
- Geo-blocked
- Source requires link-out
- Unknown error

Channel surfing behavior:

- Next/previous channel controls.
- Keyboard shortcuts.
- Preserve mute/volume where browser policy permits.
- Preserve play intent across channel changes so switching channels does not leave the new channel paused.
- Graceful transition between native HLS channels, with explicit source-detail/link-out handling for YouTube, iframe, and official-player-only channels.

## Implementation Phases

### Phase 1: Data and validator

- Done: static Swift seed catalogue for native HLS/DASH experiments and external YouTube/link-out sources.
- Done: initial direct-HLS validation and MVP stream triage.
- Done: placeholder program metadata is represented as typed `ProgramMetadata` rather than unstructured UI copy.
- Done: channel metadata now uses typed `LegalReviewStatus`, `MetadataLevel`, and `ProgramConfidence` enums.
- Remaining: keep periodic validation on the roadmap so stale feeds are detected outside manual simulator testing.

### Phase 2: Playback spike

- Done: SwiftUI playback shell works across macOS, iOS/iPadOS, and tvOS.
- Done: direct HLS uses AVPlayer/AVKit; macOS-only DASH experiment uses a web-backed player path.
- Done: channel groups, guide drawer, previous/next controls, swipe navigation on touch platforms, remote navigation, and macOS menu/keyboard commands are wired.
- Done: playback resumes on channel changes and guide-triggered versus surf-triggered chrome behavior is split.
- Done: guide cards have bounded text, compact phone landscape density, and platform-aware action overlays.
- Done: official link-out/source-detail mode supports bundled 16:9 preview captures and an experimental macOS in-app web view for YouTube-like sources.
- Done: app icon assets are present.
- Remaining: run periodic device/simulator visual checks as the UI changes, especially tvOS focus, iPad size classes, iPhone landscape, and macOS window controls.

### Phase 2b: Structure checkpoint

Current state:

- Done: `ContentView` is now primarily orchestration/state, with platform action overlays, navigation modifiers, guide rail/cards, link-out surfaces, platform players, window configuration, and collection helpers split into focused files.
- Done: `ProgramDrawer` composes `ChannelGuideRail` rather than owning the guide-group picker and channel-card implementation inline.
- Done: `PlayerSurface` owns signal/playback state while platform-specific AVKit/DASH bridges and link-out/web surfaces live in separate files.
- Done: guide taps and guide-group changes use explicit channel-selection callbacks instead of mutating the selected channel binding from deep guide views.
- Done: grouping, channel code, source-label, live-state, typed metadata, and catalogue display behavior have focused unit coverage in `ChannelGuideTests`.
- Done: loose metadata strings for legal review status, metadata level, and confidence have been converted to enums.
- Done: verification currently runs whitespace checks, `swift-format` lint, macOS tests, iPhone simulator build, iPad simulator build, and tvOS simulator build through `Scripts/verify.sh`.
- Decision for the current prototype: keep the catalogue as Swift seed data while source validation and typed metadata are still changing quickly. Revisit JSON/YAML once second-ring channels, logo provenance, and schedule-adapter mappings stabilize enough to benefit from data-only edits.

Remaining structure follow-ups:

- Keep extracting only when a file starts carrying multiple responsibilities again; avoid abstraction for its own sake.
- Consider a small persistence boundary before custom pins, recent channels, validation history, or user channel overrides grow beyond `AppStorage`.
- Add UI smoke tests for opening the guide, changing channels, hiding the guide, and checking compact phone landscape behavior.

### Phase 3: Program metadata adapters

- Done: CPAC schedule adapter maps daily TV-style schedule rows into now/next metadata with timezone handling.
- Done: Quebec webdiffusion adapter maps current live-list/upcoming metadata into current/next channel metadata.
- Done: New Zealand calendar adapter maps House next-meeting state into channel metadata.
- Done: Ontario calendar adapter maps House/committee calendar events to the known Ontario streams.
- Done: Brazil TV Camara weekly schedule adapter maps time/program rows and `AO VIVO` labels.
- Remaining: UK Parliamentlive Guide adapter: day guide, event details, room/chamber labels, agenda items.
- European Parliament webstreaming adapter: extract official Multimedia Centre REST calls before implementation.
- YouTube live/current adapter for official YouTube fallbacks.

Near-term direct-HLS schedule-adapter order:

1. UK Parliamentlive Guide: highest-value missing official schedule adapter for an existing external source.
2. European Parliament webstreaming: extract official Multimedia Centre REST calls before implementation.
3. YouTube live/current adapter: useful for the YouTube group, but keep it separate from native surf behavior.
4. Spain Congreso / Canal Parlamento: official programming pages look scrapeable, but Liferay/portal HTML adds mechanical friction.
5. Portugal ARTV: promising official agenda/export source, but likely needs session, XSRF, or structured-export handling before it is quick to implement.

Keep Netherlands, France, Denmark, Greece, Luxembourg, Mauritius, Italy, India, Thailand, Slovakia, and Nunavut as later schedule follow-ups unless a clearly structured official endpoint is found. For those, continue showing signal state and official source links rather than pretending schedule coverage exists.

### Phase 4: MVP UI

- tvOS channel rail.
- Channel groups and pinned local-priority channels.
- Full-screen player.
- Now/next overlay.
- Compact on-player mini guide.
- Source details overlay.
- Lazy HLS frame previews in guide cards: prototype `AVAssetImageGenerator` frame grabs for visible/focused native HLS cards only, cache by channel ID, limit concurrency to 1-2 requests, time out quickly, cancel/deprioritize when the guide closes or group changes, and keep text-only cards as the fallback for off-air or unsupported streams.
- Follow up on macOS AVKit floating controls: the native rewind-side control cluster can show overlapping/conflicting icons in some windows. Keep floating controls for now, but test whether a custom control strip, inline controls with a separate guide affordance, or an AVKit workaround is the best fix.
- Official logo or fallback monogram on channel cards and source-detail surfaces when rights are clear.
- App icon / visual identity pass: defer final exploration until ImageGen is reliable again, then run the Product Design ideate workflow around the "Guide Chamber" direction. Avoid columns, domes, flags, coats of arms, seals, and official marks. Explore clean identity-grade icon studies based on parliamentary seating geometry, live video, and surfable guide semantics before committing an `AppIcon` asset.
- Error/off-air/upcoming states.
- Separate non-native sources from the main surf rail until playback is validated.

### Phase 5: Hardening

- Periodic validation.
- Better off-air detection.
- Segment advancement checks.
- Captions/audio language discovery.
- i18n/l10n coverage for current stream and source-metadata languages: English, French, Portuguese, Danish, Dutch, Spanish, Greek, Luxembourgish, Italian, Hindi, Thai, Slovak, Mongolian, Inuktitut, Mandarin, and Māori.
- Treat localization as two related layers: app-shell strings for the interface, and source metadata handling for channel names, schedule titles, audio labels, captions, scripts, accents, sorting, search, and fallback text.
- Make sure the UI can render Latin text with diacritics and macrons, Greek, Devanagari, Thai, Cyrillic/Mongolian-related source text, Inuktitut syllabics where available, and Traditional/Simplified Chinese without clipping in guide cards, drawers, and compact phone layouts.
- SwiftUI app hygiene still to cover.
- Make formatting mandatory in the dev workflow with Xcode's bundled `swift-format`; keep `make format`, `make format-check`, and `make verify` aligned.
- Expand CI beyond the current GitHub Actions baseline so it also runs iPhone simulator build, iPad simulator build, and tvOS simulator build once runner images and destination names are stable.
- Revisit whether a second semantic linting layer is needed after the SwiftUI structure settles; avoid adding one until it catches issues `swift-format` and compiler warnings miss.
- Add a small UI smoke-test layer for opening the guide, changing channels, hiding the guide, and checking the compact phone landscape drawer.
- Add an accessibility pass for VoiceOver labels, focus order, Dynamic Type behavior, contrast, and remote/touch/keyboard parity.
- Add structured logging around playback failures, metadata refresh failures, schedule parser drift, channel switching, and external-source launches.
- Plan a later privacy-preserving popularity/discovery service before adding any analytics:
  - Make viewing analytics opt-in with clear settings and privacy copy.
  - Do not store accounts, raw IPs, precise GPS, or per-user viewing histories.
  - Derive approximate location server-side from IP only long enough to bucket it, then discard the raw address.
  - Store only coarse aggregate buckets such as channel ID, country/region/large-metro bucket, hour-of-day, day-of-week, month/season, and count.
  - Apply minimum contribution thresholds before displaying popularity data so niche locations or unusual times cannot identify a viewer.
  - Expose the result as discovery affordances such as a "Popular" guide group, "popular now", "often watched weekday mornings", or "trending in Canada" badges.
  - Keep this separate from the open stream catalogue: catalogue data describes public sources; popularity data describes privacy-preserving aggregate app usage.
  - Evaluate CloudKit as the Apple-native storage option: private database for per-user synced preferences, public database for app-wide aggregate popularity records, and CloudKit Console telemetry/logs for operational visibility. Do not treat CloudKit by itself as a privacy design; still require opt-in, coarse buckets, raw-data minimization, and display thresholds.
- Review app lifecycle behavior: first launch, cold start, returning from background, rotation/resizing, simulator/device orientation changes, and state restoration.
- Review platform-specific polish: tvOS focus effects, iPad size classes, iPhone landscape/portrait density, macOS window sizing, menu commands, and keyboard shortcuts.
- Add a consistent loading/off-air/error-state pattern shared across native HLS, DASH, schedule-poor channels, YouTube cards, and official link-out cards.
- Review release basics before TestFlight/App Store: signing, provisioning, app sandbox, privacy nutrition, network/privacy wording, bundle metadata, and support URL.
- Decide whether to keep local-only user preferences in `AppStorage` or introduce a small persistence boundary before adding recent channels, custom pins, or validation history.
- Apple framework review pass:
  - `AVFoundation` / `AVKit` (macOS, iOS, tvOS): deepen playback diagnostics with access/error logs, media-selection groups, timed metadata, captions, audio-language discovery, PiP, and better live-state handling.
  - `NaturalLanguage` (macOS, iOS, tvOS): lightweight language detection and title/label cleanup without requiring Apple Intelligence.
  - `Translation` (macOS, iOS, tvOS in the installed SDK): consider optional title/summary translation for bilingual and international schedule metadata after source text is trustworthy.
  - `Vision` (macOS, iOS, tvOS): consider OCR for bundled external-source screenshots or limited frame diagnostics, not as a primary schedule source.
  - `Speech` (macOS, iOS, tvOS): treat live transcription/caption experiments as later research because cost, permissions, legal, and UX implications are higher.
  - `AppIntents` (macOS, iOS, tvOS): later Shortcuts/Spotlight/Siri-style actions for opening pinned channels or source groups.
  - `SwiftData` (macOS, iOS, tvOS): consider when pins, recent channels, user channel overrides, and validation history outgrow `UserDefaults`.
  - `BackgroundTasks` (macOS, iOS, tvOS in the installed SDK): consider local refresh/validation where platform rules allow, but prefer server-side validation for durable source monitoring.
  - `GroupActivities` / SharePlay (macOS, iOS, tvOS): later synchronized watching or shared civic-session viewing, not MVP.
- Foundation Models review pass (macOS, iOS; not present as a tvOS framework in the installed Xcode 26.5 SDK): consider as an optional intelligence adapter for structured metadata extraction, verbose agenda summarization, title normalization, and source-state classification. Do not use it to invent schedule facts, validate officialness, or block the tvOS-first MVP path.
- Terms review pass.
- Logo/brand asset review pass with provenance, accessibility labels, and fallbacks.
- Periodically refresh bundled 16:9 external-source page captures, especially YouTube/link-out previews; track capture date, source URL, and any consent/sign-in/cookie UI that appears in the screenshot.
- Add stretch channels.

### Phase 5a: Public repository readiness

Current public-facing baseline:

- Done: add `README.md` with prototype scope, platform targets, build/test commands, non-affiliation language, and source/rights cautions.
- Done: add BSD 3-Clause `LICENSE` for project code.
- Done: add `docs/sources-and-provenance.md` to separate code licensing from stream/source/page-capture/design-asset rights.
- Done: add `CONTRIBUTING.md` with required evidence for source and stream corrections.
- Done: add `PRIVACY.md` describing the current local-only/no-analytics prototype posture.
- Done: add `docs/open-parliament-streams.md` as a placeholder sketch for the later public catalogue/advocacy repository.
- Done: add a conservative GitHub Actions workflow for `swift-format` lint and macOS tests.
- Done: mark `research.md` as a working research log rather than an endorsed public stream directory.
- Done: remove generated icon concept exploration assets from the public repository baseline.
- Done: add fresh macOS, iPhone, iPadOS, and tvOS screenshots to the README.
- Done: add `SECURITY.md` with lightweight sensitive-reporting guidance.
- Done: add GitHub issue templates for playback bugs, source corrections, schedule metadata issues, and UI/platform issues.
- Current CI baseline: GitHub Actions runs public-repo checks for formatting and macOS tests.

Remaining before making the repo highly presentable:

- Consider adding a short demo GIF after the UI has a stable public-facing state.
- Evaluate Xcode Cloud once the app is closer to TestFlight/App Store distribution. Use it for Apple-native build, parallel device tests, archive/signing, TestFlight delivery, and App Store Connect visibility if it adds value beyond the public GitHub Actions checks.
- Keep contribution and privacy notes current as network behavior, persistence, or validation tooling changes.

### Phase 5b: Curated second ring

Do not open a broad sub-national catalogue yet. Quebec, Ontario, and the low-confidence Nunavut HLS candidate are now grouped under `Regions`. After the Apple-first MVP is stable, add a curated second ring:

- Canada expansion: verify Nunavut official page/terms/schedule, then add BC, Alberta, Saskatchewan, and Manitoba as official-player/schedule or validated-HLS candidates.
- UK devolved parliaments: Scotland, Wales/Senedd, and Northern Ireland as official-player/schedule cards.
- Australia states: NSW, Queensland, WA, and Victoria as official-player/schedule cards.
- Germany pilot: Baden-Wurttemberg and NRW for possible direct HLS extraction.
- Lower-priority direct-HLS candidates: Jalisco and Colima only after source ownership, legislative relevance, and terms are reviewed.
- Supra-national: PACE and Nordic Council as event-based official-player cards.

Only direct HLS or AVPlayer-compatible streams should enter the main channel rail. Official-player-only sub-national and supra-national bodies should stay metadata/link-out cards until an Apple-compatible playback path is validated.

### Phase 6: Openness and standards advocacy

After the app is stable enough to demonstrate the channel-surfing model, use it as evidence for a light advocacy effort with lagging legislatures and broadcast vendors.

The advocacy goal is not to demand unrestricted rebroadcast rights. It is to encourage public parliamentary bodies to publish predictable, standards-based access points for live video, schedules, and accessibility metadata.

Core message:

- Public proceedings should be easy to access on phones, tablets, computers, TVs, and assistive devices.
- Stable documented feeds reduce scraping, broken integrations, and accidental misuse.
- Open technical access can still preserve attribution, watermarking, official source links, and clear terms.
- Schedule and event metadata make proceedings easier to cite, discover, and understand.
- Standard metadata improves accessibility by exposing captions, sign-language feeds, audio languages, room labels, committee labels, and upcoming proceedings.
- Machine-readable feeds reduce support burden because civic technologists do not need to reverse-engineer fragile web players.

Minimum standard to advocate for:

- Stable official HLS stream or documented official embed for each chamber/committee stream.
- JSON schedule endpoint with stable event IDs.
- Now/next endpoint or live-state signal.
- Source-local timezone and UTC start/end timestamps.
- Chamber, room, committee, legislature, and jurisdiction labels.
- Caption, sign-language, and audio-language metadata.
- Plain-language terms of use for non-commercial public-access apps.
- Browser and Apple-platform playback compatibility, including CORS where applicable.
- Off-air/status signal so sitting-only streams are not misclassified as broken.

Useful project artifact:

- Publish a small benchmark matrix showing which legislatures provide direct HLS, official embeds, schedule APIs, now/next metadata, captions/accessibility metadata, terms clarity, and Apple-platform compatibility.

## Biggest Risks

- Terms of use and rebroadcast/embedding permission.
- Browser playback quirks across HLS, YouTube, and official iframes.
- tvOS limitations for YouTube, web iframes, and official web-only players.
- Sitting-only streams being misclassified as broken.
- Schedule adapters drifting when official sites change.
- YouTube live IDs changing.
- Source URLs changing without notice.
- Scope creep from global and sub-national coverage.

## Current Recommendation

Proceed with a focused Apple-first MVP.

The app is feasible if it is framed as a curated parliamentary channel surfer with direct HLS as the core playback path and explicit source-quality labels. A web app still makes sense later for wider access and iframe-heavy sources, but tvOS-first is a coherent product choice because the experience is fundamentally TV-like.
