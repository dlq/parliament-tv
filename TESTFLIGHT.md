# TestFlight Readiness

This project is preparing an early TestFlight build for reviewer feedback on the cross-platform Parliaments prototype.

## App Store Connect

- App name: Parliaments
- Bundle ID: `ca.dlq.parliaments`
- SKU: `ca.dlq.parliaments`
- Primary language: English (Canada)
- First build focus: iOS/iPadOS. macOS and tvOS are present in the project, but can be added to TestFlight after archive and asset checks are clean.
- User access: Full Access for the initial app record unless App Store Connect roles need to be restricted.

## Beta Description

Parliaments is a prototype viewer for live public parliamentary video streams. It helps testers browse official public sources, switch channels, inspect available schedule metadata, pin useful streams, and review the interface across Apple platforms.

The app is not affiliated with, endorsed by, or operated by any parliament, legislature, broadcaster, or video platform. Stream names, official marks, source pages, and broadcast content belong to their respective owners.

## What To Test

- Browse live parliamentary streams and confirm playback starts reliably.
- Open and close the guide drawer.
- Switch channels with buttons, keyboard, swipe, or platform navigation where available.
- Pin and unpin useful channels.
- Review now/next schedule metadata where available.
- Review off-air, no-signal, and external-source states.
- Check localization fit, clipping, and fallback wording.
- Compare iPhone, iPad, macOS, and tvOS navigation once each platform build is available.

## Review Notes

- This build uses public official stream URLs and official public source pages.
- Some streams may be off-air, show holding slides, or provide no schedule metadata depending on sitting hours and source availability.
- YouTube and other external-source cards are marked separately from native HLS sources.
- The app currently has no accounts, advertising SDKs, analytics SDKs, telemetry SDKs, push notifications, or server-side sync.
- Pinned channel preferences are stored locally on device.

## Privacy Summary

The app makes network requests to configured parliamentary stream URLs, official source pages, schedule pages, selected external web/player sources, and macOS DASH support scripts for the experimental DASH path. External pages and video platforms may have their own logging, cookies, tracking, geolocation rules, or account prompts.

See `PRIVACY.md` for the current prototype privacy posture.

## Local Release Checks

Before uploading a build:

1. Run `make format-check`.
2. Run `make verify`.
3. Confirm `PRODUCT_BUNDLE_IDENTIFIER` is `ca.dlq.parliaments`.
4. Confirm `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` are correct for the upload.
5. Archive iOS/iPadOS first and upload through Xcode Organizer.
6. Add macOS and tvOS archives after platform-specific assets and archive signing are clean.

## Known Pre-TestFlight Follow-Ups

- Add tvOS-specific App Icon and Top Shelf brand assets before tvOS TestFlight.
- Confirm production signing and provisioning in Xcode with the Apple Developer team.
- Fill App Store Connect privacy answers from `PRIVACY.md`.
- Keep beta review notes clear that the app is an unofficial viewer for public official sources.
