# Parliamentary open-stream research

This is a working research log, not an endorsed stream directory or legal assessment. It includes successful checks, failed checks, stale candidates, third-party references, and notes that require revalidation before reuse in a public catalogue, app release, or advocacy material.

Date researched: 2026-05-12  
Goal: determine whether an app can flip between publicly available, open streams of parliamentary activity around the world, with initial coverage across national, sub-national, and supra-national legislatures.

## Bottom line

This is possible, but the first version should model sources as a mix of:

1. Direct stream channels: browser-playable HLS/DASH URLs or stable iframes that can behave like TV channels.
2. Official web-player channels: sources where the official page is public, but the stream URL is dynamic, embedded, protected by player logic, or not clearly licensed for direct reuse.
3. External-platform channels: YouTube or app-store/mobile app routes that are public but less suitable for an integrated channel-flipping app unless embedded under that platform's rules.

The target list is realistic, but the "all public bodies expose a stable first-party HLS URL" assumption is only partly true. In this pass I validated 21 HLS endpoints from official pages/APIs or official vendor players:

- CPAC: 1 official HLS URL exposed by CPAC's own content-store API and backed by Vualto/VuStreams.
- C-SPAN: partially feasible. Free/public access exists for congressional floor proceedings, hearings, and events through C-SPAN Now, but the C-SPAN, C-SPAN2, and C-SPAN3 TV network livestreams require cable/satellite authentication.
- British Parliament: feasible through Parliamentlive.tv and UK Parliament YouTube, but I did not find a stable raw HLS URL; Parliamentlive.tv uses a Red Bee player stack. BBC Parliament is geo-restricted via BBC iPlayer, so it is not a good open worldwide source.
- French Parliament: feasible through the Assemblee nationale video portal, LCP, Public Senat, and social/YouTube routes. Official direct stream URLs need further extraction/validation.
- Quebec National Assembly: 14 official-vendor Wowza HLS channel URLs validated. The official live-list API also returned current activity metadata and active channel URLs.
- Ontario Legislative Assembly: 6 official-vendor iSi LIVE HLS URLs validated for House, captioned House, committee rooms, and media studio.
- European Parliament: strong candidate through the Multimedia Centre webstreaming platform, iframe embeds, multilingual streaming, and reusable/free material with source attribution, but I did not validate a stable raw HLS URL.

## Validated stable HLS inventory

Validation date: 2026-05-12 from Montreal/Toronto region. "Official-vendor" means the URL is hosted by the legislature's streaming vendor, but was discovered from an official page, official iframe, or official API rather than from a random relay.

| Legislature/source | Count | Status |
| --- | ---: | --- |
| CPAC Canada | 1 | Official content-store API exposes HLS; validated HTTP 200. |
| Quebec National Assembly | 14 | Official live webdiffusion API exposes Wowza HLS channels; all `canal01` through `canal14` validated HTTP 200. |
| Ontario Legislative Assembly | 6 | Official pages embed iSi LIVE players; derived iSi HLS URLs validated HTTP 200. |
| C-SPAN | 0 | No unauthenticated official HLS found for the TV networks; public event/floor access appears app/page based. |
| UK Parliament | 0 | Official Parliamentlive.tv uses Red Bee player/assets; no stable raw HLS URL exposed in static/API checks. |
| French Parliament / LCP / Public Senat | 0 | Official pages exist; no validated first-party HLS found in this pass. |
| European Parliament | 0 | Official Multimedia Centre/Watchity player exists; no validated stable raw HLS found in this pass. |

Validated CPAC HLS:

```text
https://cpac-ca-live.cdn.vustreams.com/groupa/live/f9809cea-1e07-47cd-a94d-2ddd3e1351db/live.isml/.m3u8
```

Result: HTTP 200, `application/vnd.apple.mpegurl`, 2076-byte master playlist. Variants include 640x360, 960x540, 1280x720, and 1920x1080 with English and French audio groups plus closed captions.

Validated Quebec HLS pattern:

```text
https://cdn3.wowza.com/5/SVEySlNEQ0FOWXlS/diffusion/canal01/playlist.m3u8
https://cdn3.wowza.com/5/SVEySlNEQ0FOWXlS/diffusion/canal02/playlist.m3u8
...
https://cdn3.wowza.com/5/SVEySlNEQ0FOWXlS/diffusion/canal14/playlist.m3u8
```

Result: all 14 numbered channels returned HTTP 200 and `application/vnd.apple.mpegurl`. Representative playlists use 960x540 variants. The official live-list API returned active events on channels 5, 6, and 14 at the time of the check, so these should be modeled as channel URLs plus schedule/activity metadata rather than always-interesting 24/7 programming.

Validated Ontario HLS:

```text
https://origin-http-delivery.isilive.ca/live/_definst_/ontla/house-en/playlist.m3u8
https://origin-http-delivery.isilive.ca/live/_definst_/ontla/house-en-cc/playlist.m3u8
https://origin-http-delivery.isilive.ca/live/_definst_/ontla/rm151-en/playlist.m3u8
https://origin-http-delivery.isilive.ca/live/_definst_/ontla/committee_1-en/playlist.m3u8
https://origin-http-delivery.isilive.ca/live/_definst_/ontla/committee_2-en/playlist.m3u8
https://origin-http-delivery.isilive.ca/live/_definst_/ontla/media-en/playlist.m3u8
```

Result: all 6 returned HTTP 200 and `application/vnd.apple.mpegurl`. The playlists expose 1280x720 variants via `chunklist.m3u8`.

## Feasibility matrix

| Target | Feasibility | Best route | Notes |
| --- | --- | --- | --- |
| CPAC Canada | High | Official content-store HLS with official page fallback | CPAC's own content-store API exposed a Vualto/VuStreams HLS URL that returned HTTP 200. The older `iptv-org` CloudFront form returned HTTP 503, so use the official API URL form. |
| C-SPAN / US Congress | Medium | C-SPAN Now / official event pages, not the three TV network livestreams | C-SPAN Now lists live floor proceedings and hearings as accessible, but C-SPAN's three TV network livestreams are reserved for authenticated TV customers. |
| UK Parliament | High for official player, low for raw HLS | Parliamentlive.tv iframe/web player; UK Parliament YouTube for selected events | Official Parliament Live TV covers public Commons, Lords, and committees live and on demand. The player stack uses Red Bee; no stable raw HLS URL was exposed. BBC Parliament is UK/iPlayer constrained. |
| French National Assembly | High | Assemblee nationale video portal and LCP official pages | The Assembly's own portal supports live and on-demand public sessions and committee meetings. LCP explicitly says the Assembly can be watched on LCP.fr, YouTube, social platforms, and the Assembly video portal. |
| Quebec National Assembly | High | Official live-list API plus Wowza HLS | Official pages list live and upcoming webdiffusions. The official AJAX API returned `UrlSignal` HLS values, and the `canal01`-`canal14` Wowza playlists all validated. |
| Ontario Legislative Assembly | High | Official iframe or direct iSi LIVE HLS | Official pages embed iSi LIVE players; 6 official-vendor HLS playlists validated for House, captioned House, committee rooms, and media studio. |
| European Parliament | High for official player, unknown for raw HLS | Multimedia Centre webstreaming and embeds | Official audiovisual service supports live streaming and iframe embed codes. Static/API checks showed Watchity player infrastructure, but no stable raw HLS URL was validated. |

## Source notes by jurisdiction

### Canada federal: CPAC

Official evidence:

- CPAC describes itself as Canada's national, bilingual, commercial-free public affairs media organization with complete televised proceedings of Canada's Parliament.
- CPAC says its website offers live access, multiple simultaneous live video streams, and on-demand parliamentary/public-affairs video.
- CPAC video help says CPAC.ca livestreams work in modern HTML5-capable browsers.

`iptv-org` candidate:

```text
CPAC (720p)
https://d7z3qjdsxbwoq.cloudfront.net/groupa/live/f9809cea-1e07-47cd-a94d-2ddd3e1351db/live.isml/.m3u8
```

Validation result on 2026-05-12:

- `curl -I -fsSL` returned HTTP 503 from CloudFront/AWS ELB.
- Plain GET also returned HTTP 503.

Official content-store result on 2026-05-12:

- CPAC's front-page content-store component `/site/components/cpac-item-lists/livestreams.xml` points to `/site/components/episodes/CPAC_TV.xml`.
- That episode points to `/site/components/videos/CPAC_TV.xml`.
- The video item exposes this HLS URL:

```text
https://cpac-ca-live.cdn.vustreams.com/groupa/live/f9809cea-1e07-47cd-a94d-2ddd3e1351db/live.isml/.m3u8
```

Validation result:

- HTTP 200.
- Content type `application/vnd.apple.mpegurl`.
- Master playlist with 640x360, 960x540, 1280x720, and 1920x1080 variants.
- Audio groups include English and French.
- Closed captions are declared.

Assessment:

CPAC is now a validated direct-HLS candidate, but the app should still discover it from CPAC's official content-store API rather than hard-coding the older `iptv-org` CloudFront URL.

Useful sources:

- https://www.cpac.ca/about-cpac/
- https://www.cpac.ca/teacher-resources
- https://www.cpac.ca/video-help
- https://www.cpac.ca/en/

### United States: C-SPAN / Congress

Official evidence:

- C-SPAN Now's app listing says it includes live streams of U.S. Congress floor proceedings and each day's key congressional hearings/top political events.
- The same listing says access to the C-SPAN, C-SPAN2, and C-SPAN3 TV network livestreams is reserved for authenticated cable/satellite TV customers.

`iptv-org` candidate:

```text
C-SPAN 2 (720p) [Not 24/7]
https://tvpass.org/live/CSPAN2/hd
```

Assessment:

For a public/open app, avoid third-party C-SPAN TV-network relays. Include C-SPAN as an official/open event source if you can deep-link/embed official live floor/hearing feeds. Do not promise the branded C-SPAN TV channels without user authentication.

Useful sources:

- https://apps.apple.com/us/app/c-span-now/id1575769362
- https://play.google.com/store/apps/details?id=org.cspan.app

### United Kingdom: Parliamentlive.tv, UK Parliament YouTube, BBC Parliament

Official evidence:

- UK Parliament says Parliamentlive.tv has live and archived video/audio footage of all public UK Parliament events, including Commons, Lords, and committees, with an archive back to 2007.
- UK Parliament's main site links to Parliament TV live feeds and its official YouTube channel.
- BBC help says iPlayer is only available in the UK and tied to a valid UK TV licence.
- The official UK Parliament YouTube channel is verified and regularly streams selected events such as PMQs.

`iptv-org` candidate:

```text
BBC Parliament (1080p) [Geo-blocked]
https://vs-cmaf-pushb-uk-live.akamaized.net/x=4/i=urn:bbc:pips:service:bbc_parliament/iptv_mse_v0_hevc.mpd
```

Validation result on 2026-05-12:

- The BBC Parliament DASH URL returned HTTP 403 from Akamai from my location.

Parliamentlive.tv player inspection on 2026-05-12:

- Event pages expose official player iframes under `https://videoplayback.parliamentlive.tv/Player/Index/...`.
- The player uses Red Bee infrastructure with:

```text
customer: "UKParliament"
businessUnit: "ParliamentLive"
exposureBaseUrl: "https://exposure.api.redbee.live"
```

- Example player source IDs are stable event assets, not direct channel HLS URLs.
- No raw HLS URL was exposed by the static event/player HTML or the basic JSON endpoints checked.

Assessment:

Use UK Parliament's own Parliamentlive.tv/player as the main source, not BBC Parliament. BBC Parliament may be a UK-only channel option, but it is not suitable for a public worldwide open-stream list.

Useful sources:

- https://www.parliament.uk/business/parliament-tv/parliament-live-help/
- https://www.parliament.uk/watch/
- https://www.youtube.com/UKParliament
- https://help.bbc.com/hc/en-us/articles/46983028513299-Is-BBC-iPlayer-included-in-the-BBC-com-subscription

### France: Assemblee nationale, LCP, Public Senat

Official evidence:

- The Assemblee nationale video portal says it provides live and on-demand access to all public sittings plus broadcast committee and body meetings.
- LCP says major Assembly debates can be watched live on TV, LCP.fr, LCP's YouTube account, social networks, and the Assembly's own video portal.
- LCP's channel page says LCP is available on the internet, YouTube, social platforms, Twitch, and podcast; it also says LCP 100% includes original programming and essential Assembly parliamentary work.
- The French Senate states public sittings are retransmitted live on its video platform.

`iptv-org` candidates:

```text
LCP (720p) [Geo-Blocked]
https://viamotionhsi.netplus.ch/live/eds/lcp/browser-HLS8/lcp.m3u8

Public Senat 24/24
https://raw.githubusercontent.com/Sibprod/streams/main/ressources/dm/py/hls/publicsenat.m3u8
```

Validation result on 2026-05-12:

- The LCP third-party HLS check hung and then reset.
- The Public Senat raw GitHub URL returned HTTP 404.
- `https://lcp.fr/direct-lcp-5434` did not expose a raw HLS URL in the static HTML checked.
- The LCP page links to official third-party/social destinations including France TV, YouTube, Twitch, and Dailymotion.

Assessment:

French parliamentary content is clearly public online, but `iptv-org` candidates are weak. Use official LCP/Assemblee/Senat pages or YouTube embeds first. Later, inspect official player payloads for direct HLS if needed.

Useful sources:

- https://www.assemblee-nationale.fr/dyn/portail-video
- https://lcp.fr/assemblee-nationale/comment-regarder-l-assemblee-nationale-en-direct-207701
- https://lcp.fr/la-chaine/regarder-lcp-assemblee-nationale-174335
- https://lcp.fr/direct-lcp-5434
- https://www.senat.fr/le-senat-et-vous/assister-aux-seances.html

### Quebec: Assemblee nationale du Quebec

Official evidence:

- The Canal de l'Assemblee page says the channel airs more than 2,000 hours of production, including National Assembly sittings, parliamentary committees, press conferences, and institutional events.
- The live webdiffusion pages list live and upcoming webcasts, with archives posted shortly after proceedings.

Static HTML inspection:

- `https://www.assnat.qc.ca/fr/video-audio/en-direct-webdiffusion.html` did not expose direct `m3u8` or `mpd` URLs in static HTML.
- The page relies on JavaScript refresh functions for live/upcoming videos.
- The live list API is `/Gabarits/RefonteVA_Accueil.aspx/ObtenirListeEnDirect` and expects a JSON-ish payload like `{codeLangue : 'fr'}`.

Official API/HLS result on 2026-05-12:

- The live-list API returned active events with `UrlPage`, `UrlSignal`, `NomCanal`, and `DiffusionDisponible`.
- Active examples returned by the API included channels 5, 6, and 14:

```text
https://cdn3.wowza.com/5/SVEySlNEQ0FOWXlS/diffusion/canal05/playlist.m3u8
https://cdn3.wowza.com/5/SVEySlNEQ0FOWXlS/diffusion/canal06/playlist.m3u8
https://cdn3.wowza.com/5/SVEySlNEQ0FOWXlS/diffusion/canal14/playlist.m3u8
```

- I then validated the full numbered channel pattern from `canal01` through `canal14`; all 14 returned HTTP 200 and content type `application/vnd.apple.mpegurl`.
- Representative playlist shape:

```text
#EXT-X-STREAM-INF:BANDWIDTH=219965,CODECS="avc1.4d401f,mp4a.40.2",RESOLUTION=960x540
chunklist.m3u8
```

Assessment:

Feasible as direct HLS plus official activity metadata. The channel URLs look stable, but the app should use the official API to know which channels currently carry meaningful proceedings.

Useful sources:

- https://www.assnat.qc.ca/fr/video-audio/canal-assemblee/index.html
- https://www.assnat.qc.ca/fr/video-audio/en-direct-webdiffusion.html
- https://www.assnat.qc.ca/fr/video-audio/direct.html?canal=6
- https://www.assnat.qc.ca/fr/video-audio/direct.html?canal=10

### Ontario: Legislative Assembly of Ontario

Official evidence:

- Ontario's official page says all House proceedings can be watched live on the House video page, along with some committee meetings from rooms 151, 1, and 2.
- Official pages embed iSi LIVE iframes. Examples:

```text
https://video.isilive.ca/ontla/house-en-new.html
https://video.isilive.ca/ontla/rm151-en-new.html
https://video.isilive.ca/ontla/committee-1-en.html
https://video.isilive.ca/ontla/committee-2-en.html
https://video.isilive.ca/ontla/media-en.html
```

`iptv-org` candidates:

```text
Legislative Assembly of Ontario
https://temp3.isilive.ca/live/_definst_/ontla/house-en/playlist.m3u8

Ontario Parliamentary Network (720p)
https://origin-http-delivery.isilive.ca/live/_definst_/ontla/house-en/playlist.m3u8
```

Validation result on 2026-05-12:

- `https://origin-http-delivery.isilive.ca/live/_definst_/ontla/house-en/playlist.m3u8` returned HTTP 200, content type `application/vnd.apple.mpegurl`, and `Access-Control-Allow-Origin: *`.
- The playlist contains a 1280x720 variant via `chunklist.m3u8`.
- The `temp3.isilive.ca` URL also returned HTTP 200.
- The iSi player HTML exposes `data-client_id="ontla"` and `data-stream_name` values. Validated stream names:

```text
house-en
house-en-cc
rm151-en
committee_1-en
committee_2-en
media-en
```

- All 6 `origin-http-delivery.isilive.ca` HLS URLs for those stream names returned HTTP 200 and `application/vnd.apple.mpegurl`.

Assessment:

Ontario is one of the strongest direct-channel candidates. Use the official page/iframe for provenance and compliance, and keep the HLS URLs as implementation candidates if playback and terms check out.

Useful sources:

- https://www.ola.org/en/get-involved/watch-legislature-action
- https://www.ola.org/en/legislative-business/video
- https://www.ola.org/en/whats-happening/watch-new-committees-livestreams
- https://apps.apple.com/ca/app/parlance/id1520014900

### European Parliament

Official evidence:

- The European Parliament Audiovisual Services page says it offers live streaming for parliamentary activity including committee meetings, plenary sessions, press conferences, institutional events, and ceremonies.
- It supports simultaneous streaming of up to 20 meeting rooms, multilingual playback, multi-device playback, downloads, and iframe embed codes for live and VOD streams.
- The Multimedia Centre page says materials are open and free of charge for media and citizens, reusable with attribution to the European Union / EP.
- Europe by Satellite offers free EU-related information and education material.

Assessment:

This is a strong supra-national target. The app can probably integrate via official webstreaming URLs/embeds first, then add schedule-aware channel cards for plenary, committees, and press events.

Static/API inspection on 2026-05-12:

- `https://multimedia.europarl.europa.eu/en/webstreaming` is a Next.js app.
- The page references `https://player.watchity.com` and `https://wbep.watchity.net/v1/wbe`.
- Event API URLs such as `https://api.multimedia.europarl.europa.eu/en/euroscola_20260512-1000-SPECIAL-EUROSCOLA` redirected to `/c` in direct `curl` checks, even with browser-like headers.
- No raw HLS URL was validated in this pass.

Useful sources:

- https://www.europarl.europa.eu/website/multimedia-centre/en/webstreaming.html
- https://www.europarl.europa.eu/news/en/media-services/multimedia-centre
- https://multimedia.europarl.europa.eu/en/webstreaming
- https://www.europarl.europa.eu/website/multimedia-centre/en/europe-by-satellite.html
- https://audiovisual.ec.europa.eu/en/ebs/about

## `iptv-org` findings

The current `iptv-org` legislative playlist had 367 lines when fetched on 2026-05-12:

```text
https://iptv-org.github.io/iptv/categories/legislative.m3u
```

Target-relevant entries found:

- BBC Parliament: present, marked geo-blocked, DASH URL returned 403 in my test.
- C-SPAN 2: present through `tvpass.org`, not an official source and not suitable as canonical.
- CPAC: present, older CloudFront-form direct HLS URL returned 503 in my test; CPAC's official API exposed the working VuStreams URL separately.
- LCP: present, marked geo-blocked, third-party Swiss-looking HLS URL did not validate cleanly.
- Public Senat: present, but raw GitHub URL returned 404 in my test.
- Ontario Legislative Assembly / Ontario Parliamentary Network: present and validated successfully for the House stream; official page inspection found 5 more Ontario HLS channels.
- Quebec: no relevant Quebec National Assembly entry found in the Canada or legislative playlists by text search; official API inspection found 14 HLS channels.
- European Parliament: no obvious direct European Parliament entry found by text search.

Conclusion: `iptv-org` is useful as a seed list, but it is not complete enough and includes unofficial/fragile stream URLs. The app should keep its own curated source registry with provenance, validation status, and fallback type.

## Managed player platforms

Some targets use professional managed video platforms rather than exposing simple static HLS URLs.

### Red Bee

Red Bee Media is a managed OTT/video platform used by broadcasters and rights owners. For Parliamentlive.tv, the official player stack exposes Red Bee configuration such as:

```text
customer: "UKParliament"
businessUnit: "ParliamentLive"
exposureBaseUrl: "https://exposure.api.redbee.live"
```

This is probably integrable in a channel-based app, but not in the same simple way as a direct HLS playlist. The practical paths are:

1. Embed or deep-link the official Parliamentlive.tv player/event page.
2. Investigate whether the Red Bee player SDK/API allows anonymous playback for UK Parliament assets.
3. Avoid treating dynamically resolved Red Bee manifests as permanent channel URLs unless the parliament documents or permits that usage.

### Watchity

Watchity is a live-streaming/video platform that supports managed players, event URLs, HLS delivery, APIs, embed codes, and CDN distribution. Within the original target set, the only confirmed Watchity-backed target so far is the European Parliament Multimedia Centre/webstreaming stack:

```text
https://player.watchity.com
https://wbep.watchity.net/v1/wbe
```

This may integrate better than Red Bee if an official embed or documented event/player URL is available, but I did not validate a stable raw HLS URL for European Parliament in this pass.

Adjacent expansion candidate:

- Parliament of Catalonia / Canal Parlament appears to use or have used Watchity. A Catalan Parliament procurement document references Watchity, SL for web video player accessibility work, and a public Canal Parlament example surfaced through `player.watchity.com`.

### Comparison with YouTube

For channel-surfing UX, the integration order is:

1. Direct HLS: best native channel feel and player control.
2. Official embeddable player: workable, but less control over player UI and switching behavior.
3. YouTube embed: stable and familiar, but YouTube-branded and governed by YouTube embed/API rules.
4. Provider SDK/API such as Red Bee or Watchity: potentially strong, but requires provider-specific integration and permission checks.
5. Scraped manifest URLs: useful for diagnostics, but fragile and risky as canonical sources.

## Prioritization revision: Democracy Index first

The initial request to cover all Commonwealth, Francophonie, and OECD countries is useful for long-term completeness, but it is too broad for efficient discovery. A better next pass is to prioritize countries by The Economist Democracy Index, then use membership lists as secondary coverage tags.

Reasoning:

- Countries ranked as full democracies are more likely to have active, public legislative broadcasting, stable official websites, accessible archives, and clearer public-service media norms.
- The current broad `iptv-org` validation pass already supports this: many working national parliamentary HLS candidates cluster in high-scoring democracies or relatively institutionally mature parliamentary systems.
- Bloc membership is noisy. The Commonwealth, Francophonie, and OECD sets mix full democracies, flawed democracies, hybrid regimes, authoritarian regimes, microstates, countries without active parliamentary TV, and countries where the legislature may not be the relevant public video publisher.

The Democracy Index page says the index covers 167 countries and territories and classifies them into full democracies, flawed democracies, hybrid regimes, and authoritarian regimes. On 2026-05-12, the page text/snippets were inconsistent about whether the 2025 table has 25 or 26 full democracies. The table section itself lists 25 full democracies, with France immediately below the line as rank 26 and "flawed democracy" at 7.99. Use the 25 table-listed full democracies as Tier 1; also keep France as a near-threshold edge case because it was mentioned in the page text and is directly relevant to the original app target.

```text
Norway
New Zealand
Sweden
Iceland
Switzerland
Finland
Denmark
Ireland
Netherlands
Luxembourg
Australia
Taiwan
Germany
Canada
Uruguay
Japan
United Kingdom
Costa Rica
Austria
Mauritius
Estonia
Spain
Czech Republic
Portugal
Greece
```

Near-threshold edge case checked anyway:

```text
France
```

Early signal from the `iptv-org` validation pass:

| Tier 1 country | Current signal |
| --- | --- |
| Canada | Validated CPAC HLS plus Ontario/Quebec subnational streams. |
| Denmark | Folketinget HLS candidate returned HTTP 200. |
| Germany | Bundestag `Parlamentsfernsehen 1` HLS returned HTTP 200; other listed Bundestag channels returned 404. |
| Greece | Hellenic Parliament TV HLS returned HTTP 200. |
| Luxembourg | Chamber TV HLS returned HTTP 200. |
| Netherlands | Multiple Tweede Kamer HLS room/channel streams returned HTTP 200. |
| New Zealand | Parliament TV HLS returned HTTP 200. |
| Portugal | ARTV Canal Parlamento HLS returned HTTP 200. |
| Spain | Congreso/Canal Parlamento HLS streams returned HTTP 200. |
| United Kingdom | Official Red Bee/Parliamentlive.tv player route found; no stable raw HLS validated. |
| Ireland | Oireachtas HLS candidates exist but returned HTTP 403 in direct validation; official fallback needs browser/player inspection. |
| Australia, Sweden, Norway, Switzerland, Finland, Taiwan, Uruguay, Japan, Costa Rica, Austria, Mauritius, Estonia, Czech Republic | No validated direct HLS yet from the seed pass; target official sites and YouTube/official player fallbacks next. |

Suggested research order from here:

1. Finish Tier 1 full democracies first, looking for direct HLS, official embed/player fallback, and official YouTube live fallback.
2. Then process flawed democracies with known `iptv-org` parliamentary hits, especially Italy, Brazil, South Korea, Mexico, India, Thailand, Bangladesh, and Malaysia.
3. Then fill Commonwealth/Francophonie/OECD gaps only where they add meaningful geographic or language coverage.

Useful source:

- https://en.wikipedia.org/wiki/The_Economist_Democracy_Index#List_by_country

## Tier 1 full-democracy stream validation pass

Date of pass: 2026-05-12.

Scope: all 25 countries currently listed in the Democracy Index 2025 table as "Full democracy", plus France as a near-threshold edge case. I validated direct HLS/DASH only where an actual manifest URL returned HTTP 200 or the official page itself published a manifest URL. Otherwise I recorded the best official fallback: first-party player, official embedded player, or official YouTube/live page.

Summary:

- Validated direct HLS: 10 of 25 full-democracy countries.
- Official player/page/YouTube fallback but no stable direct manifest validated: 15 of 25.
- France, although not in the current table's full-democracy group, has an official National Assembly direct HLS URL that returned HTTP 200.

| Country | Direct HLS/DASH validation | Viable fallback | Evidence and notes |
| --- | --- | --- | --- |
| Norway | Not validated. | Official Stortinget Nett-TV via Qbrick player. | Official page `https://www.stortinget.no/nett-tv` contains Qbrick account `AccrjW9C7ikYk2xPM5xJ4Frag` and media ids for Storting chamber and rooms. Good app fallback as an official player, but no raw manifest confirmed. |
| New Zealand | Validated HLS 200. | Official Parliament TV page. | `https://ptvlive.kordia.net.nz/out/v1/daf20b9a9ec5449dadd734e50ce52b74/index.m3u8` returned HTTP 200 with HLS content type. |
| Sweden | Not validated. | Official Riksdag broadcasts page. | `https://www.riksdagen.se/en/contact-and-visit/media/broadcasts/` exposes webcast/live-video UI strings, but no stable raw manifest was found in static HTML. |
| Iceland | Not validated. | Official Althingi site remains target fallback; seed HLS failed. | `iptv-org` candidate `https://althingi-live.secure.footprint.net/althingi/live/index.m3u8` failed DNS resolution during validation. Official page fetching also returned 403 in this environment, so this needs browser/manual follow-up. |
| Switzerland | Player exposes HLS-like Akamai endpoints, but direct manifest checks returned 404 when tested. | Official `parlament.ch` Simplex player. | `https://www.parlament.ch/en` includes Simplex live player URLs such as `https://par-pcache.simplex.tv/content?externalid=-1&enableHLS=1`; fetched player config exposed Akamai `manifest.m3u8` values, but they were inactive/404 at validation time. |
| Finland | Not validated. | Official Eduskunta webcasts site. | `https://verkkolahetys.eduskunta.fi/` is official and served a modern webcast app using Videosync CDN assets; no stable raw manifest was extracted from static HTML. |
| Denmark | Validated HLS 200. | Official Folketinget/Kaltura player. | `https://cdnapi.kaltura.com/p/2158211/sp/327418300/playManifest/entryId/1_24gfa7qq/protocol/https/format/applehttp/a.m3u8` returned HTTP 200. |
| Ireland | Direct HLS candidates returned 403. | Official Oireachtas TV pages and embed codes. | Official page `https://www.oireachtas.ie/en/oireachtas-tv/` states live debates are available and links Dail, Seanad, committee rooms CR1-CR4, and Oireachtas TV Channel. It also says embed codes for live streams are available, but direct CloudFront HLS candidates returned 403 without the player context. |
| Netherlands | Validated HLS 200. | Official Tweede Kamer live system. | Example: `https://livestreaming.b67buv2.tweedekamer.nl/live/plenairezaal/index.m3u8?hd=1&keyframes=1&subtitles=live` returned HTTP 200; multiple room streams also validated. |
| Luxembourg | Validated HLS 200. | Official Chamber TV page/player. | `https://media02.webtvlive.eu/chd-edge/smil:chamber_tv_hd.smil/playlist.m3u8` returned HTTP 200. |
| Australia | Not validated. | Official YouTube channel and APH live page. | `https://www.aph.gov.au/live?ps=10` points users to official `@AUSParliamentLive` on YouTube and APH ParlView for VOD. This is a strong YouTube/channel-surfing fallback, not first-party HLS. |
| Taiwan | Not validated. | Official Parliamentary TV YouTube embeds and IVOD page. | `https://www.parliamentarytv.org.tw/` embeds official YouTube live content and links Channel 1, Channel 2, Legislative Yuan meeting playlist, and `https://ivod.ly.gov.tw/Live`. |
| Germany | Validated HLS 200 for channel 1. | Official Bundestag Parlamentsfernsehen. | `https://cldf-hlsgw.r53.cdn.tv1.eu/1000153copo/hk1.m3u8` returned HTTP 200. Other listed Bundestag channels returned 404. |
| Canada | Validated HLS 200. | CPAC official live service; also strong provincial HLS coverage. | CPAC official HLS `https://cpac-ca-live.cdn.vustreams.com/groupa/live/f9809cea-1e07-47cd-a94d-2ddd3e1351db/live.isml/.m3u8` returned HTTP 200 with multi-bitrate HLS, English/French audio, and captions. |
| Uruguay | Not validated. | Official Parliament/YouTube channels. | `https://parlamento.gub.uy/` links official YouTube channels for Parlamento, TV Senado, and TV Diputados. No stable first-party HLS was found. |
| Japan | Official HLS template found, but no active room manifest validated. | Official House of Representatives Internet TV. | `https://www.shugiintv.go.jp/en/` includes hidden HLS template `http://hlslive.shugiintv.go.jp/_roomid_/amlst:_roomid_/playlist.m3u8`; tested likely `main` room returned 404 after redirect, probably because no matching live room was active. |
| United Kingdom | Not validated. | Official Parliamentlive.tv via Red Bee player. | Official Parliamentlive.tv player URLs are viable for embedded/browser fallback. No stable raw HLS was found. |
| Costa Rica | Not validated. | Official Asamblea Legislativa YouTube channel. | Official YouTube channel `https://www.youtube.com/@AsambleaCRC` is reachable and suitable as a YouTube fallback. No first-party HLS found. |
| Austria | Not validated. | Official Parlament Osterreich Mediathek. | `https://www.parlament.gv.at/aktuelles/mediathek` is the official media/live entry point; static page did not expose a stable raw manifest. |
| Mauritius | Validated HLS 200. | Official Parliament TV player. | Official player page exposed `https://d3haas31wb246g.cloudfront.net/live/88d4336f-f9bb-4dae-a567-41608b05f529/live.isml/live.m3u8`, which returned HTTP 200 with a Unified Streaming Platform HLS playlist and variants. |
| Estonia | Not validated. | Official Riigikogu live pages and YouTube archive/channel. | Official page `https://www.riigikogu.ee/en/news-and-publications/multimedia/live-broadcast/` embeds `https://www.riigikogu.ee/live/1/en` and `https://www.riigikogu.ee/live/2/en`; also links official YouTube playlists/channels. |
| Spain | Validated HLS 200. | Official Congreso/Canal Parlamento streams. | `https://congresodirecto.akamaized.net/hls/live/2037973/canalparlamento/master.m3u8` returned HTTP 200; additional Congreso room/channel HLS streams also validated. |
| Czech Republic | Not validated. | Official Chamber of Deputies iframe. | `https://pspen.psp.cz/live-broadcast/` embeds `https://utils.ssl.cdn.cra.cz/live-streaming/clients/pspcr/player-cra.php`; player was inactive during validation and showed no current stream. |
| Portugal | Validated HLS 200. | Official ARTV/Canal Parlamento. | `https://playout172.livextend.cloud/liveiframe/_definst_/liveartvabr/playlist.m3u8` returned HTTP 200. |
| Greece | Validated HLS 200. | Official Hellenic Parliament TV. | `https://ert-ucdn.broadpeak-aas.com/bpk-tv/VOULITV/default/index.m3u8` returned HTTP 200. |

Near-threshold edge case:

| Country | Direct HLS/DASH validation | Viable fallback | Evidence and notes |
| --- | --- | --- | --- |
| France | Validated HLS 200 for National Assembly. | Official National Assembly video portal and Senate video portal; LCP/Public Senat/YouTube as broader parliamentary TV fallbacks. | `https://videos.assemblee-nationale.fr/direct.php` published `http://assemblee-nationale.akamaized.net/live/live36/stream36.m3u8`, which returned HTTP 200 as an HLS playlist. Senate official page `https://videos.senat.fr/video/seance_direct.html` is a viable official player fallback, but no raw Senate HLS was extracted. |

Engineering interpretation:

- A channel-surfing app is feasible, but the source model cannot assume "stable first-party HLS everywhere".
- Direct HLS should be first-class where validated, because it enables the cleanest player/channel model.
- Official player/page and YouTube fallbacks need to be first-class too. Many high-quality legislatures use vendor players, session-conditioned manifests, or YouTube as the stable integration surface.
- The app should store validation status and last-validated timestamp separately from channel identity, because some legislative streams are valid only during sittings.

## Tier 2 flawed-democracy stream validation pass

Date of pass: 2026-05-12.

Scope: all 46 countries currently listed in the Democracy Index 2025 table as "Flawed democracy".

Method: reuse the prior `iptv-org` legislative-playlist HTTP validation where available, then add official parliament/player/YouTube fallbacks from official sites or recognizable official parliamentary broadcasters. "Validated direct" here means the manifest URL returned HTTP 200 during this research. It does not always mean first-party, production-safe, or legally reusable.

Summary:

- Flawed-democracy countries in current table: 46.
- Direct HLS/DASH returned HTTP 200 for at least one parliamentary or legislative-adjacent feed: 10 of 46.
- Strongest production candidates from this tier: France, Italy, India, Brazil, Thailand, Slovakia, and possibly Malaysia if geo/legal constraints are acceptable.
- Several "working" direct URLs are not clean first-party sources, especially South Korea's GitHub-proxied National Assembly TV entry, Mongolia's SkyGo DASH, and Moldova's Privesc.eu relay.
- Most remaining countries have viable official page/YouTube/player fallbacks rather than stable raw manifests.

| Country | Direct HLS/DASH validation | Viable fallback | Evidence and notes |
| --- | --- | --- | --- |
| France | Validated HLS 200 for National Assembly. | Official National Assembly video portal; Senate official video portal; LCP/Public Senat as broader parliamentary TV fallbacks. | `https://videos.assemblee-nationale.fr/direct.php` published `http://assemblee-nationale.akamaized.net/live/live36/stream36.m3u8`, which returned HTTP 200. `iptv-org` LCP/Public Senat entries did not validate, but the Assembly source is strong. |
| Malta | `iptv-org` HLS returned 406. | Official Parliament of Malta live-streaming page. | Candidate `https://stream.smashmalta.com:25463/live/webplayer/livestream/23.m3u8` returned HTTP 406. Use official `parliament.mt` live-streaming/player page as fallback. |
| United States | Not validated. | C-SPAN, HouseLive, Senate floor/webcast pages. | No open stable first-party HLS found. App integration should treat C-SPAN as an official/editorial broadcaster fallback, with U.S. House and Senate first-party pages as separate event/player fallbacks. |
| Chile | `iptv-org` HLS returned 503. | Official Camara TV / Senado TV pages. | Candidate `http://camara.03.cl.cdnz.cl/camara19/live/playlist.m3u8` returned HTTP 503. Fallback should use official chamber/senate video pages. |
| Slovenia | Not validated. | Official Drzavni zbor live/video page. | No validated raw manifest from the seed list. Treat as official-page/player fallback until a manifest is extracted during an active sitting. |
| Israel | `iptv-org` HLS returned 404. | Official Knesset Channel site/player. | Candidate `https://contact.gostreaming.tv/Knesset/myStream/playlist.m3u8` returned HTTP 404. `https://www.knesset.tv/live/` is the official player fallback. |
| South Korea | Direct streams returned 200, but production suitability is mixed. | Official National Assembly TV / Korea TV pages. | `https://hlive.ktv.go.kr/live/klive_h.stream/playlist.m3u8` returned HTTP 200; `iptv-org` National Assembly TV entry also returned 200 but via a GitHub-hosted playlist, so it should not be treated as stable official infrastructure. |
| Latvia | Not validated. | Official Saeima live/video archive page. | Official Saeima page says it provides live streams and video archive, and notes broadcasts are also on Parliament Facebook/YouTube. Embedding requires permission. No raw manifest validated. |
| Belgium | Not validated. | Official Chamber/Senate streaming pages and YouTube fallbacks. | No stable direct manifest validated in this pass. Treat as official-player fallback; revisit with browser network inspection during a sitting. |
| Botswana | Not validated. | Official Parliament site/YouTube fallback target. | No direct manifest found in seed validation. Official fallback needs browser confirmation. |
| Lithuania | Not validated. | Official Seimas broadcast/player pages. | No direct manifest validated. Treat official Seimas page/player as fallback. |
| Cape Verde | Not validated. | Official Assembleia Nacional site/YouTube fallback target. | No direct manifest found in seed validation. Official fallback needs browser confirmation. |
| Italy | Validated HLS 200. | Official Camera/Senato pages; Senato direct stream is strongest. | `https://senato-live.morescreens.com/SENATO_1_001/playlist.m3u8` returned HTTP 200. Camera entry `https://video-ar.radioradicale.it/diretta/camera2/playlist.m3u8` also returned 200 but is via Radio Radicale, not a clean first-party URL. |
| Poland | Not validated. | Official Sejm transmissions page. | No raw manifest validated. Official page `sejm.gov.pl` exposes live/session transmissions and is the correct fallback surface. |
| Cyprus | Not validated. | Official House of Representatives live/video page target. | No direct manifest found in seed validation. Official fallback needs browser confirmation. |
| India | Validated HLS 200. | Official Sansad TV pages/apps. | `https://d2lk5u59tns74c.cloudfront.net/out/v1/fff8f20221d5456e8922e689d71dedc3/index.m3u8` and `https://d2lk5u59tns74c.cloudfront.net/out/v1/e4182054dce340da9e0ff38b6b3658a4/index.m3u8` returned HTTP 200. Strong candidate, pending terms/CORS checks. |
| Slovakia | Validated HLS 200. | Official National Council / TV NRSR pages. | `https://n11.stv.livebox.sk/stv-tv/stv4.stream/playlist.m3u8` returned HTTP 200. It is a public-broadcaster distribution path, not necessarily first-party parliament infrastructure. |
| South Africa | Not validated. | Official Parliament live-streaming page and YouTube channel. | No raw manifest validated. Official `parliament.gov.za` live-streaming page is a viable fallback. |
| Malaysia | Validated HLS 200, geo-marked. | Official RTM Parlimen pages. | Dewan Negara `https://d25tgymtnqzu8s.cloudfront.net/smil:negara/playlist.m3u8?id=8` and Dewan Rakyat `https://d25tgymtnqzu8s.cloudfront.net/smil:rakyat/playlist.m3u8?id=7` returned HTTP 200 but are marked geo-blocked in the seed list. |
| Trinidad and Tobago | Not validated. | Official Parliament Channel live stream. | No raw manifest validated. `ttparliament.org` live stream is the expected official fallback. |
| Timor-Leste | Not validated. | No robust fallback validated in this pass. | Needs manual/browser follow-up against official parliament and government media channels. |
| Panama | Not validated. | Official Asamblea Nacional / Asamblea TV fallback. | No direct manifest validated. Use official Asamblea site or official video/social channel as fallback. |
| Suriname | Not validated. | Official National Assembly site fallback target. | No direct manifest found; fallback still needs browser confirmation. |
| Jamaica | Not validated. | Official Parliament/PBC Jamaica/YouTube fallback. | No direct manifest validated. Jamaica parliamentary proceedings are commonly surfaced through official parliament/PBCJ video channels. |
| Montenegro | `iptv-org` direct candidate returned 403. | Official Skupstina / parliamentary TV fallback. | TVCG 3 candidate returned HTTP 403. Use official parliament/player/YouTube fallback. |
| Philippines | Not validated. | Official House and Senate YouTube/live pages. | No raw manifest validated. House of Representatives and Senate official YouTube streams are likely the practical channel-surfing fallback. |
| Dominican Republic | Not validated. | Official Chamber/Senate video pages and YouTube channels. | No direct manifest validated. Official legislature video pages/channels are viable fallbacks. |
| Mongolia | Validated DASH 200. | Official parliament/media page fallback. | `https://cdn4.skygo.mn/live/disk1/Parlament/DASH-FTA/Parlament.mpd` returned HTTP 200. This is a SkyGo distribution URL, so production use needs ownership/terms review. |
| Argentina | Not validated. | Official Diputados/Senado live pages and YouTube channels. | No direct manifest validated. Strong official fallback surfaces exist, but raw HLS was not found in this pass. |
| Hungary | `iptv-org` HLS candidates timed out. | Official Orszaggyules web-TV pages. | `http://plenaris.parlament.hu:1935/edgelive/smil:mkogyplen.smil/playlist.m3u8` and `http://tab.parlament.hu:1935/edgelive/smil:mkogytab.smil/playlist.m3u8` timed out. Treat as sitting-only candidate plus official player fallback. |
| Croatia | Not validated. | Official Sabor video/live pages. | No direct manifest validated. Official Sabor video transmissions are the fallback. |
| Brazil | Validated HLS 200. | Official TV Camara / Canal Gov pages. | `https://stream3.camara.gov.br/tv1/manifest.m3u8` returned HTTP 200. `https://canalgov-stream.ebc.com.br/index.m3u8` also returned 200 but is broader government TV rather than legislature-specific. |
| Namibia | Not validated. | Official Parliament site/YouTube fallback target. | No direct manifest found in seed validation. Official fallback needs browser confirmation. |
| Indonesia | Validated HLS 200. | Official TVR Parlemen / DPR pages. | `http://103.18.181.69:1935/golive/livestream/playlist.m3u8` returned HTTP 200. The raw IP URL is fragile; official page/player fallback should be preferred unless a stable host is found. |
| Colombia | Not validated. | Official Canal Congreso / Senate / Chamber video pages. | No raw manifest validated. Official Canal Congreso or legislature pages are the fallback. |
| Bulgaria | Not validated. | Official National Assembly live/video pages. | No direct manifest validated. Treat as official-player fallback. |
| North Macedonia | Candidate timed out. | Official Assembly / Sobraniski kanal fallback. | `https://vipottbpkstream.vip.hr/Content/onevip-hls/Live/Channel(Sobraniski_Kanal)/index.m3u8` timed out. The seed labels it geo-blocked; official fallback needs browser validation. |
| Thailand | Validated HLS 200. | Official Thai Parliament TV page. | `https://tv-live.tpchannel.org/live/tv.m3u8` returned HTTP 200. Strong direct candidate, pending CORS/terms checks. |
| Serbia | Not validated. | Official National Assembly live/video pages. | No direct manifest validated. Official-player fallback only. |
| Ghana | Not validated. | Official Parliament live/YouTube fallback. | No direct manifest validated. Official fallback needs browser confirmation. |
| Albania | Not validated. | Official Kuvendi live/video page fallback. | No direct manifest validated. Treat as official-player fallback. |
| Sri Lanka | Not validated. | Official Parliament webcast/YouTube fallback. | No direct manifest validated. Official fallback needs browser confirmation. |
| Singapore | Not validated. | Official Parliament video/live page fallback. | No direct manifest validated. Singapore's official surface is more event/session based than TV-channel-like. |
| Guyana | Not validated. | Official Parliament live/YouTube fallback. | No direct manifest validated. Official fallback needs browser confirmation. |
| Lesotho | Not validated. | No robust fallback validated in this pass. | Needs manual/browser follow-up against official parliament and national broadcaster channels. |
| Moldova | Validated HLS 200, but third-party. | Official Parliament site/player should be preferred if found. | `https://cachestar.privesc.eu/liniar/moldova/playlist.m3u8` returned HTTP 200, but it is Privesc.eu rather than first-party parliament infrastructure. Treat as a relay/fallback, not a canonical source. |

Engineering interpretation for this tier:

- The flawed-democracy tier has more direct manifests than expected, but fewer clean first-party manifests than the raw count suggests.
- YouTube and official-player fallback support is essential here. Without it, coverage drops sharply.
- For an app, do not mix first-party parliamentary feeds, public-broadcaster relays, and third-party mirrors under one generic "stream" label. Store `source_owner` and `legal_review_status`.
- Several candidates are sitting-only. A validator should distinguish "404 because no sitting is active" from "broken URL"; this requires scheduled rechecks during known plenary hours.

## Implementation implications for a future app

## Pre-implementation risk review

Date of pass: 2026-05-12.

This pass checked the risks identified after the tier research: playback/CORS, terms of use, schedules, YouTube integration, source-quality taxonomy, and remaining product risks.

### Playback and CORS probe

I could not run a full Playwright/browser decode in this workspace because browser automation tooling was not available. Instead, I ran a browser-like HTTP probe with an `Origin` header against the likely MVP direct-stream candidates. This is not a substitute for testing `<video>`/`hls.js` playback in Chrome, Safari, and mobile Safari, but it catches the first-order blockers: HTTP status, content type, CORS headers, and playlist shape.

Result: all tested direct HLS candidates returned HTTP 200 and had permissive or origin-reflecting CORS headers.

| Channel | HTTP/content | CORS signal | Playlist signal | App risk |
| --- | --- | --- | --- | --- |
| CPAC | 200 `application/vnd.apple.mpegurl` | `Access-Control-Allow-Origin: *` | HLS master, 4 variants | Technically strong; terms are restrictive, so do legal review before public redistribution. |
| Quebec canal05 | 200 HLS | `*` | HLS master, 1 variant | Technically strong; non-commercial/reasonable-use terms. |
| Ontario house-en | 200 HLS | `*` | HLS master, 1 variant | Technically strong; non-commercial/excerpt terms need care for app framing. |
| New Zealand Parliament TV | 200 HLS | Reflected test origin | HLS master, 6 variants | Technically strong; terms explicitly allow broadcast/rebroadcast under conditions. |
| Denmark Folketinget | 200 HLS | `*` | HLS master, 1 variant | Technically strong; still needs terms review. |
| Netherlands Tweede Kamer | 200 HLS | `*` | HLS master, 5 variants | Technically strong; includes `Range`/token-related CORS headers. |
| Portugal ARTV | 200 HLS | `*` | HLS master, 1 variant | Technically strong; terms review still needed. |
| Spain Congreso | 200 HLS | `*` | HLS master, 1 variant | Technically strong; terms review still needed. |
| Greece Hellenic Parliament TV | 200 HLS | `*` | HLS master, 5 variants | Technically strong; terms review still needed. |
| Luxembourg Chamber TV | 200 HLS | `*` | HLS master, 5 variants | Technically strong; terms review still needed. |
| Mauritius Parliament TV | 200 HLS | `*` | HLS master, 4 variants | Technically strong; terms review still needed. |
| France National Assembly | 200 HLS | `*` | Live media playlist, 3 segments | Technically strong; single live playlist rather than master. |
| Italy Senate | 200 HLS | `*` | HLS master, 5 variants | Technically strong; terms review still needed. |
| India Sansad TV 1 | 200 HLS | `*` | HLS master, 5 variants | Technically strong; terms and geo/reliability review still needed. |
| Brazil TV Camara | 200 HLS | `*` | Live media playlist, 3 segments | Technically strong and terms look unusually permissive for legislative activities. |
| Thailand Parliament TV | 200 HLS | `*` | HLS master, 6 variants | Technically strong; terms and geo/reliability review still needed. |
| Slovakia TV NRSR | 200 HLS | `*` | HLS master, 1 variant | Technically strong; likely public-broadcaster distribution rather than first-party. |

Implementation note: direct HLS playback still needs real browser testing. The probe suggests these are likely compatible with `hls.js` on desktop Chromium/Firefox and native HLS on Safari, but segment-level CORS and mixed-content handling must be verified in a real app.

### Terms and reuse policy findings

Terms are the largest non-technical risk. The app should not infer permission from an accessible manifest.

| Source | Terms signal | App implication |
| --- | --- | --- |
| CPAC | CPAC terms cover audio-video feeds and other content as protected content owned by CPAC/licensors; terms are website-use oriented and CPAC can suspend access. Source: `https://www.cpac.ca/terms-of-use` | Treat as playable official source for personal use/prototype; do not present as openly reusable without permission. |
| Quebec Assembly | Content, including video/audio, may be reproduced without fees if use is reasonable, fair, non-commercial, unmodified, non-prejudicial, and credited; debates may be reproduced subject to the National Assembly Act, while other use may need authorization. Source: `https://www.assnat.qc.ca/fr/propos-site/droits-propriete-intellectuelle.html` | Good local exception for a non-commercial app/prototype; commercial/public product needs review. |
| Ontario Assembly | Electronic channels include video streaming services; excerpts may be used if reasonable, fair, non-commercial, credited, and subject to parliamentary privilege/IP limits. Source: `https://www.ola.org/en/office-assembly/copyright-privacy` | Good local exception for non-commercial app/prototype; be careful about full-stream rebroadcast framing. |
| UK Parliamentlive.tv | Help page says embedding capability is temporarily suspended; live coverage remains on Parliamentlive.tv and UK Parliament YouTube and can be linked. Conditions restrict use to fair and accurate reports, prohibit many commercial/advertising uses, and recordings are personal-use oriented. Sources: `https://www.parliament.uk/site-information/using-this-website/help/parliamentlivetv-help/`, `https://www.parliament.uk/site-information/copyright-parliament/pru-licence-agreements/downloading--sharing-terms--conditions/` | Use official page links or YouTube fallback first. Avoid embedding raw Parliamentlive players until terms and current embed availability are confirmed. |
| European Parliament | Multimedia Centre says live streaming, VOD, downloads, and iframe embed codes are available; content is described as open/free with source attribution in EP news material, but live embed codes may need advance request. Sources: `https://www.europarl.europa.eu/website/multimedia-centre/en/webstreaming.html`, `https://www.europarl.europa.eu/news/en/media-services/multimedia-centre` | Strong official fallback. Prefer official embed/player and schedule integration over raw manifest extraction. |
| New Zealand Parliament TV | Terms explicitly allow live coverage to be made available for broadcast, webcast, and recording, with restrictions against misleading use, commercial advertising/sponsorship, and legal non-compliance. Source: `https://www3.parliament.nz/en/get-involved/information-for-the-press/parliament-tv-terms-and-conditions/` | One of the cleanest direct HLS candidates. |
| Brazil TV Camara | Terms say live retransmissions of legislative activities generated by the Chamber are under CC BY 4.0; watermark/source must not be removed. Other programs use more restrictive CC BY-NC-ND. Source: `https://www.camara.leg.br/tv/termos-de-uso/` | Very strong candidate for lawful app integration of legislative activity streams if attribution and watermark integrity are preserved. |
| YouTube sources | YouTube embeds are governed by YouTube API/player terms; privacy-enhanced mode is available via `youtube-nocookie.com`; autoplay has privacy and browser-policy implications. Sources: `https://developers.google.com/youtube/player_parameters`, `https://developers.google.com/youtube/iframe_api_reference`, `https://support.google.com/youtube/answer/57788` | Use official embeds, not extracted YouTube HLS. Expect branding, cookie/consent, autoplay, ad, and availability constraints. |

### Schedule and live-state research

The app should not just show a static list of streams. It needs live-state and schedule metadata because many channels are sitting-only or event-based.

| Source | Schedule/live-state signal | App implication |
| --- | --- | --- |
| CPAC | `https://www.cpac.ca/schedule` exposes a full schedule with time-zone controls and program entries, including House of Commons Proceedings, Senate Proceedings, Question Period, committees, and Public Record. | Scrape or manually ingest schedule cards; CPAC is TV-like and 24/7, but "parliamentary activity now" still needs program classification. |
| Quebec Assembly | Official live-list API previously returned active channels/events, and official pages link parliamentary work to video. Public pages also expose weekly parliamentary calendars. | Use the live-list API for current active streams; use weekly calendar pages as a fallback. |
| Ontario Assembly | Official calendar page lists House and committee events and includes watch-livestream markers. Official watch page states live streaming covers all House proceedings and some committee rooms. Sources: `https://www.ola.org/en/legislative-business/calendar`, `https://www.ola.org/en/get-involved/watch-legislature-action` | Strong schedule integration candidate. Map events to known `house`, `rm151`, `committee_1`, `committee_2`, and media streams. |
| UK Parliament | Parliamentlive.tv has Brief Guide, Full Event Guide, Commons/Lords/committee pages, RSS of recent events, and official help. Sources: `https://www.parliamentlive.tv/Guide`, `https://www.parliament.uk/site-information/using-this-website/help/parliamentlivetv-help/` | Treat UK as schedule-first official-player integration, not raw stream integration. |
| European Parliament | Multimedia Centre has a streaming schedule and can provide iframe embed codes; audiovisual services mention simultaneous streaming of many rooms. Sources: `https://multimedia.europarl.europa.eu/en?lang=en`, `https://www.europarl.europa.eu/website/multimedia-centre/en/webstreaming.html` | Treat as schedule-first official-player integration with multilingual metadata. |
| New Zealand Parliament | Help page says PTV broadcasts live during House sittings and points users to the Parliament Calendar for dates/times. Source: `https://www.parliament.nz/en/footer/website-help/the-parliament-tv-help-page/` | Pair direct HLS with sitting calendar to avoid showing a dead or uninteresting channel. |
| UK/EP/YouTube fallbacks | Official pages often know upcoming event state better than raw players. | The channel model needs `schedule_url`, `schedule_source_type`, and `current_event` separate from `playback_url`. |

### Schedule metadata discovery pass

Date of pass: 2026-06-06.

Goal: estimate how much "EPG-like" information the app can reasonably get from official sources, without assuming every source has a cable-TV-style programme guide.

Conclusion: a focused MVP can have useful now/next or daily schedule metadata. A universal EPG is unrealistic, but an "EPG-lite" layer is feasible for the strongest official sources. The schedule layer should be source-specific adapters rather than one generic parser.

| Source | Official schedule surface | Format observed | Metadata available | Confidence | Adapter difficulty | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| CPAC | `https://www.cpac.ca/schedule/` | Server-rendered HTML | Daily TV-style schedule, UTC `data-airdate`, title, description, timezone controls. | High | Low-medium | Strongest TV-like schedule. Need classify whether current show is parliamentary, committee, public record, or rebroadcast. |
| Assemblee nationale du Quebec | `https://www.assnat.qc.ca/fr/video-audio/index.html`; JSON methods under `/Gabarits/RefonteVA_Accueil.aspx/ObtenirListeEnDirect` and `/ObtenirListeAVenir` | Official JSON responses | Current live webdiffusions and upcoming webdiffusions with date, time range, committee/chamber labels, and titles. | High | Medium | Very good local source. Needs French time parsing and mapping events to the correct `canalNN` stream. On a non-sitting Saturday, live list returned empty and upcoming list returned multiple June 8-10, 2026 events. |
| Legislative Assembly of Ontario | `https://www.ola.org/en/legislative-business/calendar` | Drupal server-rendered calendar HTML with day/week/month navigation and AJAX view plumbing | House and committee events by day, plus watch/live context from official watch pages. | Medium-high | Medium | Curl needs a browser user-agent. Good MVP source, but stream-to-room mapping still needs testing on sitting days. |
| UK Parliament / Parliamentlive.tv | `https://www.parliamentlive.tv/Guide`, `/Guide/EpgDay?date=...`, `/Guide/EpgInfo/<eventId>`, `http://data.parliamentlive.tv/api/event/feed` | HTML guide partials, event pages, Atom feed | Channel lanes, event IDs, rooms, chamber/committee labels, day schedule, event details, agenda items, start/end times on event pages. | High | Medium | Best true EPG-like source found. Playback remains official-player/YouTube-first, but metadata is strong enough for a channel guide. |
| European Parliament | `https://multimedia.europarl.europa.eu/en/webstreaming` | Next.js SSR plus API config for `api.multimedia.europarl.europa.eu` and `/o/epmp-frontend-rest/v1.0` | Streaming agenda for plenaries, committees, press conferences, and events. | High-promise | Medium-high | Strong schedule target. Exact REST endpoint still needs extraction from Next.js chunks or network inspection. Watchity player config is visible in page data. |
| New Zealand Parliament | `https://www3.parliament.nz/en/calendar/`; `https://www3.parliament.nz/en/pb/meetings-of-parliament/` | Official calendar HTML, RSS/export links, House sitting programme export | Current "House next meets" state, day/week/month calendar, committee events, House Business filters, sitting programme export, normal sitting hours. | High | Medium | Good partner for direct Parliament TV HLS. Calendar says next meeting and exposes event rows; urgency/extended hours can change late and must be refreshed. |
| Brazil TV Camara | `https://www.camara.leg.br/tv/programacao-semanal` | Static weekly HTML tables | Weekly programme schedule with time/program rows and explicit `AO VIVO` labels. | High | Low | Strong lawful/technical candidate if attribution and terms are respected. Easy EPG-lite adapter. |
| Portugal Assembleia da Republica | `https://agenda.parlamento.pt/` | Official agenda app with AJAX handlers and export options | Structured agenda by section, XML/JSON/PDF export options, ICS-style content download path. | High-promise | Medium | Requires session/XSRF handling for structured export. Good later adapter because the source is explicitly agenda-oriented. |
| Spain Congreso | `https://www.congreso.es/en/programacion` | Liferay portlet HTML | Canal Parlamento weekly programming pages and date-driven schedule URLs. | Medium-high | Medium | Scrapeable, but Liferay portlet shape adds mechanical complexity. |
| France Assemblee nationale | `https://www.assemblee-nationale.fr/seance/` | Official HTML agenda pages plus PDF agenda documents | Order of business, commission agendas, future scheduling PDFs. | Medium | Medium-high | Good official metadata exists, but less channel-like. Direct page is video-first; schedule likely needs agenda/PDF parsing. |
| Netherlands Tweede Kamer | `https://www.tweedekamer.nl/contact-en-bezoek/volg-de-tweede-kamer-online`, linked plenary/committee agenda pages, Debat Direct | Official pages and app/site links | Official live/replay and debate agenda surfaces are clearly linked. | Medium-promise | Medium-high | Needs a follow-up pass against plenary/committee pages and Debat Direct to identify structured endpoints. |
| Denmark Folketinget | Official TV/schedule pages | Not fetched successfully in this environment | Likely official plenary/meeting schedule. | Unknown | Unknown | Official site returned 403 to curl, even with a browser user-agent. Needs browser/manual pass before classification. |
| Australia APH | `https://www.aph.gov.au/News_and_Events/Watch_Read_Listen` and APH calendar/watch surfaces | Not fetched successfully in this environment | Likely calendar plus official watch surfaces; YouTube scheduled streams may help. | Medium-promise | Medium-high | Official APH pages returned 403 to curl. Needs browser/manual pass and/or YouTube scheduled-live investigation. |
| YouTube-backed sources | Official YouTube channel live pages and scheduled events | YouTube web/API surfaces | Current live state, scheduled live events, titles, thumbnails, channel identity when API access is available. | Medium | Medium-high | Useful fallback, but not a stable EPG. Avoid extracted manifests; use official embed/player semantics. |

Practical metadata tiers for the MVP:

| Tier | Sources | App behavior |
| --- | --- | --- |
| Strong now/next and daily schedule | CPAC, Quebec, UK Parliamentlive, New Zealand, Brazil TV Camara | Show now/next overlay, upcoming rail, off-air/upcoming states, and refresh on a timer. |
| Good but needs endpoint extraction | European Parliament, Portugal, Spain, Ontario | Include behind feature flags or adapter spikes; promote once parsing survives a sitting-day test. |
| Official but less channel-like | France, Netherlands, Australia, Denmark | Keep as source-detail cards or link-out/official-player entries until structured metadata and playback behavior are validated. |
| Weak/no schedule | Raw HLS feeds with no official calendar mapping | Show signal state only: online/offline, last validated time, and source page link. |

Recommended adapter order:

1. CPAC schedule adapter.
2. Quebec webdiffusion live/upcoming adapter.
3. UK Parliamentlive guide adapter.
4. New Zealand calendar/sitting adapter.
5. Ontario calendar adapter.
6. Brazil TV Camara weekly schedule adapter.
7. European Parliament webstreaming adapter after extracting exact REST calls.
8. Portugal and Spain agenda/programming adapters.

Implementation notes:

- Store schedules independently from playback URLs. Some of the best schedules belong to sources whose playback path is official-player or YouTube rather than direct HLS.
- Normalize all events to source timezone plus UTC start/end. Display in the user's locale but keep source-local times available because parliamentary schedules are often published that way.
- Add confidence and freshness fields. A Saturday "no live event" result is valid, not a stream failure.
- Expect late changes. Parliamentary schedules move, sit under urgency, or add extended hours; adapters should refresh more aggressively near sitting times.
- Keep a manual override path for MVP launch. A small curated channel lineup can tolerate hand-corrected channel-to-room mappings while parser confidence improves.

### YouTube channel-surfing model

YouTube is viable, but it is not the same as HLS channel surfing.

Recommended model:

- Store YouTube as `source_type: youtube_embed`, not `direct_hls`.
- Prefer official channel handles/playlists and official site embeds.
- Use a `youtube_channel_id`, optional `default_live_video_id`, and optional `live_playlist_id`.
- Resolve "what is live now" by page/API discovery, not by assuming one permanent video id unless the legislature uses one.
- Use `youtube-nocookie.com` where possible for privacy-enhanced embeds.
- Use the IFrame Player API with `enablejsapi=1` and `origin=<app-origin>` if building custom controls.
- Expect autoplay to be blocked unless muted or initiated by user gesture; the YouTube IFrame API exposes `onAutoplayBlocked`.
- Do not extract or proxy YouTube HLS manifests. That would be brittle and likely contrary to platform rules.

YouTube integration risks:

- Live events can end and be replaced with a new video id.
- Some channels use playlists; others use fixed "live" URLs; some schedule one-off events.
- Ads, overlays, branding, captions, age restrictions, embedding-disabled videos, regional blocks, and cookie consent can interrupt a TV-like UX.
- YouTube embeds require a minimum viewport and visible controls/branding constraints. They should be a channel-card player mode, not hidden background plumbing.

### Source-quality taxonomy

Use these fields from the beginning:

```text
source_type:
  direct_hls
  direct_dash
  official_embed
  official_page
  youtube_embed
  app_store_app

source_owner:
  first_party_legislature
  official_vendor
  official_public_broadcaster
  official_youtube
  official_social
  third_party_relay
  community_playlist

legal_review_status:
  not_reviewed
  personal_use_only
  noncommercial_with_attribution
  explicit_reuse_allowed
  embed_only
  link_only
  permission_required
  avoid

technical_status:
  validated_playlist
  validated_browser_playback
  cors_ok
  active_now
  inactive_sitting_only
  blocked
  geo_blocked
  broken
  unknown

schedule_source_type:
  none
  official_calendar
  official_live_api
  official_schedule_page
  youtube_api
  manual
```

Minimum channel fields to add beyond the earlier model:

```text
display_mode: native_player | iframe | youtube | link_out
schedule_url
terms_url
attribution_text
requires_user_gesture
supports_captions
audio_languages
caption_languages
last_browser_playback_check_at
last_legal_review_at
```

### Additional product risks

- Commercialization: several promising sources are explicitly non-commercial or prohibit commercial sponsorship/advertising near proceedings.
- Re-broadcast framing: even where viewing is public, framing a raw stream inside another app may count differently than linking or using supplied embed code.
- Parliamentary privilege: many jurisdictions preserve privilege and integrity rules for proceedings; edited clips, overlays, commentary, or misleading context can be restricted.
- Attribution and watermark integrity: Brazil and Quebec explicitly care about source attribution; Brazil explicitly prohibits removing/suppressing the Chamber watermark.
- Internationalization: captions, simultaneous interpretation, sign language, and floor/original audio should be modeled early, especially for CPAC, European Parliament, Luxembourg, and multilingual parliaments.
- Accessibility: some sources have captions but expose them through sidecar WebVTT or player-specific captions; CORS must be checked for caption files too.
- Live/off-air UX: a sitting-only stream can be technically healthy and still show no event. The UI needs states like `off air`, `next sitting`, `rebroadcast`, `live`, and `unknown`.
- Monitoring burden: stream URLs will drift. Treat all direct URLs as monitored data with automated revalidation and manual override.
- Jurisdictional geo behavior: Malaysia, BBC Parliament, and some public-broadcaster relays may return 200 from one location and fail elsewhere.
- User trust: distinguish first-party legislature, official broadcaster, official YouTube, and third-party/community relay visibly.

### Recommended next build gate

Before building broad catalogue features, create a tiny playback spike with:

1. Direct HLS: CPAC, Quebec, Ontario, New Zealand, Brazil.
2. Official iframe/page: UK Parliamentlive.tv, European Parliament.
3. YouTube: Australia or Taiwan.
4. Schedule/live state: Ontario calendar, CPAC schedule, UK Parliamentlive Guide.
5. Legal labels: CPAC `permission_required/personal-use caution`, Quebec/Ontario `noncommercial`, New Zealand/Brazil `explicitly usable with conditions`, YouTube `platform embed`.

Pass criteria:

- Desktop Chrome plays all direct HLS via `hls.js`.
- Safari plays direct HLS natively.
- YouTube channel card can be swapped with keyboard/controller-like channel controls.
- Off-air streams show a clear state instead of looking broken.
- Every channel displays source owner, terms status, and official-source link.

### Comparable app and UI references

This app should borrow from live-TV and IPTV apps more than from generic streaming catalogues.

Closest direct references:

- [Channels: Whole Home DVR](https://apps.apple.com/us/app/channels-whole-home-dvr/id1405359767): live TV, Apple TV, guide data, DVR, favorites, and cross-device viewing. Strong reference for a simple, family-friendly live-TV mental model.
- [IPTVX](https://apps.apple.com/us/app/iptvx/id1451470024): iOS/tvOS IPTV app with EPG grid, live zapping, on-player EPG, favorites, iCloud sync, and EPG search. Strong reference for polished playlist/channel management and on-player metadata.
- [iPlayTV](https://apps.apple.com/us/app/iplaytv-iptv-m3u-player/id1072226801): Apple TV-only IPTV player with EPG, channel preview, favorites, frame-rate matching, audio tracks, and subtitles. Strong reference for tvOS-first simplicity.
- [TivEPG](https://tivepg.com/): iOS/tvOS IPTV app that describes a Sky Glass-style horizontal EPG and Siri Remote-first experience. Useful reference for now/next timeline browsing.
- [SWIPTV](https://apps.apple.com/us/app/swiptv-iptv-player/id1658538188): modern IPTV player with live EPG, previews, multi-device support, playlist refresh, PiP, and metadata enhancements. Useful reference for current IPTV feature expectations.

Polished large-screen references:

- [HBO Max](https://www.macrumors.com/2025/12/04/apple-announces-2025-app-store-awards/) won Apple TV App of the Year in the 2025 App Store Awards. Study accessibility, large-screen navigation, and content-detail polish rather than its catalogue/storefront model.
- Apple's [tvOS 26 design direction](https://images.apple.com/uk/newsroom/2025/06/apple-tv-brings-a-beautiful-redesign-and-enhanced-home-entertainment-experience/) emphasizes keeping focus on what is playing with unobtrusive UI. That fits this app better than card-heavy browsing.
- Netflix's Apple TV custom-player changes drew criticism because they removed familiar native tvOS affordances. The lesson is to stay close to AVPlayer/native tvOS playback behavior where possible.

UI ideas to steal:

- Full-screen video first, metadata overlays second.
- Remote-first channel up/down.
- A horizontal now/next rail instead of a dense EPG grid for MVP.
- On-player mini guide: current channel, current event, next event, source, language/captions.
- Favorites/local priority pinning for Quebec, Ontario, and CPAC.
- Visible but restrained source-quality badges: `Official HLS`, `Official vendor`, `Official YouTube`, `Link out`, `Schedule only`.
- Intentional off-air states: `Off air`, `Next sitting at 10:00`, `Schedule unavailable`, or `Signal available, program unknown`.
- Avoid hiding source trust. First-party parliament video, official broadcaster feeds, official YouTube, and third-party relays should look distinct.

Use a channel model like:

```text
id
name
jurisdiction_level: national | subnational | supranational
country_or_region
legislature
source_type: direct_hls | direct_dash | official_iframe | official_page | youtube | app_only
source_owner: first_party | official_vendor | third_party
playback_url
official_url
source_status: verified | candidate | blocked | broken | auth_required
availability: 24_7 | sitting_only | event_based | unknown
geo_notes
auth_notes
last_checked_at
validation_result
```

Recommended minimum viable channel list:

1. CPAC: official content-store HLS, with CPAC live page fallback.
2. Quebec Assembly: 14 official-vendor HLS channels plus official live-list API metadata.
3. Ontario: 6 official-vendor HLS channels plus official iframe fallback.
4. UK Parliament: official Parliamentlive.tv route, likely event/schedule driven.
5. European Parliament: official Multimedia Centre webstreaming route, schedule driven.
6. French Assembly/LCP: official Assembly video portal and LCP direct page.
7. C-SPAN: mark as official/event-source only; avoid unauthenticated TV-network relays.

## Open questions / next research tasks

- Determine whether CPAC has additional live HLS feeds beyond the main CPAC TV stream.
- Map Quebec channel numbers to stable room/feed names and decide how to present inactive channels.
- Inspect LCP / Assemblee nationale / Public Senat official player network calls for direct HLS and CORS behavior.
- Determine whether Parliamentlive.tv/Red Bee and European Parliament/Watchity permit embedding outside their own pages or whether only deep-linking is appropriate.
- Build a stream validator that periodically checks HTTP status, CORS headers, playlist shape, and browser playback success.
- Review terms of use for each source before redistributing direct stream URLs in a public app.

## Non-US sub-national and additional supra-national discovery pass

Date of pass: 2026-06-06.

Scope: a bounded discovery pass for sub-national legislative streams outside U.S. states, plus a light pass over additional supra-national parliamentary bodies. This is intentionally not a comprehensive global sub-national crawl.

Method:

- Re-fetched the current `iptv-org` legislative playlist.
- Excluded U.S. state/municipal-style entries.
- Searched for non-U.S. sub-national legislative names and obvious terms: province, territory, Landtag, autonomous parliament, devolved parliament, live stream, webcast, plenary.
- Validated direct HLS entries where the playlist exposed a manifest.
- Used official-source web searches for Canada, Australia, UK devolved parliaments, German Landtage, Spanish autonomous parliaments, and supra-national parliamentary assemblies.

Current `iptv-org` signal:

- The current legislative playlist has 181 entries.
- Non-U.S. sub-national direct candidates found in the playlist are concentrated in Canada, Spain, and Mexico.
- Outside `iptv-org`, many sub-national legislatures have official live/archived webcasts and calendars, but not obvious stable raw HLS.
- Primary raw-stream source checked: https://iptv-org.github.io/iptv/categories/legislative.m3u

### Direct sub-national HLS candidates found

| Jurisdiction | Legislature/channel | Validation | Notes |
| --- | --- | --- | --- |
| Quebec, Canada | Assemblee nationale du Quebec, canal01-canal14 | Previously validated HTTP 200 for all 14 Wowza HLS channels. | Strong local-priority exception; official live-list API gives active channel/event metadata. |
| Ontario, Canada | Legislative Assembly of Ontario / Ontario Parliamentary Network | Validated HTTP 200 for official iSi HLS. | Strong local-priority exception; 6 known iSi HLS channels. |
| Nunavut, Canada | Legislative Assembly TV Nunavut | HTTP 200 HLS via `temp2.isilive.ca`. | Useful Canadian territorial candidate. Needs official page/terms confirmation before app inclusion. |
| British Columbia, Canada | Legislative Assembly of BC House and Committee A | Current `iptv-org` HLS candidates timed out during validation. | Official page confirms live webcasts, YouTube availability, weekly broadcast schedule, parliamentary calendar, committee calendar, captions, ASL streams, and archives. Strong official fallback even though direct HLS did not validate in this pass. |
| Jalisco, Mexico | Canal Parlamento del Congreso de Jalisco | HTTP 200 HLS. | Direct HLS candidate from `iptv-org`; not a priority for Apple-first MVP, but proof that non-U.S. sub-national direct HLS exists outside Canada. |
| Colima, Mexico | ICRTV Colima | HTTP 200 HLS. | Legislative-adjacent/regional channel candidate from `iptv-org`; source quality needs review. |
| Valencia, Spain | Corts Valencianes | Candidate timed out. | Official site prominently says live parliamentary activity can be followed and has agenda/calendar pages. `iptv-org` HLS did not validate in this pass. |
| Andalucia, Spain | Parlamento de Andalucia | Candidate failed connection. | `iptv-org` raw IP/port candidate did not connect. Treat as official-page search target, not a direct candidate yet. |

### High-yield official fallback targets

These should be treated as official page/player/calendar candidates first. Direct HLS should only be added if extracted and validated later.

| Country/system | Jurisdictions worth checking | Evidence from this pass | App implication |
| --- | --- | --- | --- |
| Canada | BC, Alberta, Saskatchewan, Manitoba, Nunavut, plus existing Quebec/Ontario. | BC official page confirms House/committee live webcasts, YouTube, schedules, calendars, captions, ASL, and archives. Alberta streams live proceedings and committees on its website plus YouTube/X/Facebook. Saskatchewan provides live video stream, committee streams, captions, archives, and sitting calendar. Manitoba has an official House Broadcasts page with sitting-hour availability and iframe. | Canada is the best sub-national expansion path. Add BC/Nunavut first after Quebec/Ontario if terms/playback check out. |
| Australia | NSW, Victoria, Queensland, Western Australia, and likely other states/territories. | NSW has official chamber webcast pages and copyright conditions. Victoria has a Watch page and live captioned proceedings. Queensland has live/archived chamber and committee broadcasts with detailed broadcast conditions. Western Australia has live Assembly/Council broadcast pages, calendar, captions, and strict use conditions. | Australia has strong official-player/calendar coverage, but terms are often restrictive. Good later expansion, not direct-HLS-first. |
| United Kingdom devolved parliaments | Scotland, Wales/Senedd, Northern Ireland. | Scottish Parliament TV has live/archived chamber and committee meetings. Senedd TV provides live and archived Plenary/committee coverage. Northern Ireland Assembly TV exposes multiple scheduled live streams with language/accessibility variants. | Very strong official-player/schedule candidates. For tvOS, likely link-out or metadata-first unless direct Apple-playable streams are found. |
| Germany | NRW, Baden-Wurttemberg, Bavaria, Berlin and other Landtage. | NRW official page says it livestreams plenary debates and hearings; pages expose HLS-style playlist paths. Baden-Wurttemberg has four live channels and an exposed HLS URL pattern in page text. Bavaria has official livestreams and YouTube for selected committee sessions, plus accessible streams and archives. | Germany is promising for official HLS extraction, but not for a quick full crawl. Prioritize Baden-Wurttemberg/NRW/Bavaria if expanding. |
| Spain | Catalunya, Valencia, Andalucia, Basque Country, Galicia and other autonomous parliaments. | Catalunya official site has Canal Parlament and live broadcast sections. Valencia official site has Canal Corts, live activity language, agenda/calendar, and an `iptv-org` candidate that timed out. Andalucia has a failed raw HLS candidate. | Spain is promising but fragmented. Treat as a later regional cluster rather than MVP scope. |
| Belgium | Regional/community parliaments. | Not deeply checked in this pass. Earlier national pass already showed Belgium needs official player/YouTube inspection. | Defer unless a specific Belgian regional parliament becomes important. |
| Switzerland/Austria | Cantonal/Landtag streams. | Not deeply checked in this pass. Likely official webcasts exist, but breadth is high and channel value is low for MVP. | Defer. Too many entities for current payoff. |

Representative official sources checked:

- BC Legislative Assembly broadcasts and webcasts: https://www.leg.bc.ca/index.php/parliamentary-business/broadcasts-and-webcasts
- Legislative Assembly of Alberta watch page: https://www.assembly.ab.ca/assembly-business/watch-the-assembly
- Legislative Assembly of Saskatchewan watch page: https://www.legassembly.sk.ca/legislative-business/watch-legislative-proceedings/
- Manitoba Legislative Assembly committees/broadcast references: https://www.manitoba.ca/legislature/committees/index.html
- Scottish Parliament live/watch page: https://www.parliament.scot/news-and-parliament-tv.aspx
- Senedd TV: https://www.senedd.tv/
- Northern Ireland Assembly TV: https://niassembly.tv/

### Additional supra-national discovery

The supra-national opportunity is more manageable than sub-national, but most bodies are event/session-based rather than channel-like.

| Entity | Signal | App implication |
| --- | --- | --- |
| European Parliament | Already a strong official schedule/player target through Multimedia Centre webstreaming. | Keep as the primary supra-national candidate. |
| Parliamentary Assembly of the Council of Europe (PACE) | Council of Europe live webcast portal carries PACE plenary/session material and VOD. | Strong event-based official-player candidate. Add to supra-national watchlist. |
| Nordic Council | Official Nordic co-operation site hosts live broadcasts/session pages with iframes; Riksdag also hosted Nordic Council plenary video. | Good annual/session-based candidate, especially for schedule cards rather than channel surfing. |
| NATO Parliamentary Assembly | Official NATO PA pages expose live streaming online meetings/session pages; NATO also streams Secretary General remarks at PA sessions. | Event-based candidate. Not a core channel. |
| OSCE Parliamentary Assembly | OSCE live page and PA meeting pages indicate plenary/live-streamed sessions. | Event-based candidate; likely official page/link-out. |

Representative official supra-national sources checked:

- European Parliament Multimedia Centre: https://multimedia.europarl.europa.eu/en
- PACE live webcast portal: https://pace.coe.int/en/pages/live-web
- Nordic Council / Nordic co-operation live and session pages: https://www.norden.org/en
- NATO Parliamentary Assembly: https://www.nato-pa.int/
- OSCE live portal: https://www.osce.org/live

### Search strategy that works

Use `iptv-org` first for raw direct candidates:

```text
https://iptv-org.github.io/iptv/categories/legislative.m3u
```

Then search official sites with patterns like:

```text
site:<official-domain> livestream parliament
site:<official-domain> webcast legislature
site:<official-domain> live broadcast chamber
site:<official-domain> plenary live stream
site:<official-domain> m3u8
"<jurisdiction>" "legislative assembly" "live stream"
"<jurisdiction>" parliament "webcast"
"<jurisdiction>" parliament YouTube live
```

For German-speaking jurisdictions:

```text
site:<official-domain> Livestream Landtag
site:<official-domain> Plenum Livestream
site:<official-domain> Mediathek Landtag Live
site:<official-domain> playlist.m3u8
```

For Spanish autonomous parliaments:

```text
site:<official-domain> directo parlamento
site:<official-domain> retransmisión en directo pleno
site:<official-domain> canal parlamento directo
site:<official-domain> m3u8
```

### Recommendation

Do not open a broad sub-national catalogue yet. A useful next step is a curated second ring:

1. Canada expansion: BC and Nunavut, after Quebec/Ontario.
2. UK devolved: Scotland, Wales/Senedd, Northern Ireland as official-player/schedule cards.
3. Australia states: NSW, Queensland, WA, Victoria as official-player/schedule cards.
4. Germany pilot: Baden-Wurttemberg and NRW for possible direct HLS extraction.
5. Supra-national: PACE and Nordic Council as event-based official-player cards.

For the Apple-first MVP, only direct HLS or AVPlayer-compatible streams should enter the main channel rail. Official-player-only sub-national/supra-national bodies should be metadata/link-out cards until an Apple-compatible playback path is validated.
