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

These are included because they are personally relevant and already validated.

| Channel | Source type | Metadata target | Notes |
| --- | --- | --- | --- |
| Quebec National Assembly canal05/canal06/canal14 seed set | Direct HLS | current event from live-list API | Keep all 14 known channels in data, but surface active channels first. |
| Ontario Legislative Assembly House EN | Direct HLS | current/next from OLA calendar | Add committee/media channels after playback spike. |

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

Default rules:

- Prefer official source pages and supplied embed codes where available.
- Do not proxy or rehost streams.
- Do not strip watermarks.
- Do not extract YouTube HLS.
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

Channel card should show:

```text
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
- Graceful transition between HLS, YouTube, iframe, and link-out channels.

## Implementation Phases

### Phase 1: Data and validator

- Create static channel catalogue.
- Add direct HLS validator.
- Add metadata placeholders.
- Validate MVP direct streams.

### Phase 2: Playback spike

- Build minimal SwiftUI/tvOS player view.
- Add AVPlayer playback for direct HLS.
- Add channel rail and remote next/previous.
- Add official link-out/source-detail mode.
- Test spike channel set on tvOS simulator/device and iOS simulator.

### Phase 3: Program metadata adapters

- CPAC schedule adapter: daily TV-style schedule, now/next overlay, timezone handling.
- Quebec webdiffusion adapter: current live list plus upcoming webdiffusions.
- UK Parliamentlive Guide adapter: day guide, event details, room/chamber labels, agenda items.
- New Zealand calendar adapter: House next-meeting state, sitting programme, calendar rows.
- Ontario calendar adapter: House/committee calendar and stream-room mapping.
- Brazil TV Camara weekly schedule adapter: time/program rows and `AO VIVO` labels.
- European Parliament webstreaming adapter: extract official Multimedia Centre REST calls before implementation.
- YouTube live/current adapter for official YouTube fallbacks.

### Phase 4: MVP UI

- tvOS channel rail.
- Full-screen player.
- Now/next overlay.
- Source details overlay.
- Error/off-air/upcoming states.

### Phase 5: Hardening

- Periodic validation.
- Better off-air detection.
- Segment advancement checks.
- Captions/audio language discovery.
- Terms review pass.
- Add stretch channels.

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
