//
//  PlatformPlayers.swift
//  Parliaments
//
//  Created by Codex on 2026-06-13.
//

import AVKit
import SwiftUI

#if os(macOS)
  import WebKit
#endif

struct PlatformDASHPlayer: View {
  let url: URL

  var body: some View {
    #if os(macOS)
      MacDASHPlayer(url: url)
    #else
      DASHUnsupportedSurface()
    #endif
  }
}

#if os(macOS)
  private struct MacDASHPlayer: NSViewRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator {
      Coordinator()
    }

    func makeNSView(context: Context) -> WKWebView {
      let configuration = WKWebViewConfiguration()
      configuration.allowsAirPlayForMediaPlayback = true
      configuration.mediaTypesRequiringUserActionForPlayback = []

      let webView = WKWebView(frame: .zero, configuration: configuration)
      webView.setValue(false, forKey: "drawsBackground")
      loadIfNeeded(webView, context: context)
      return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
      loadIfNeeded(webView, context: context)
    }

    private func loadIfNeeded(_ webView: WKWebView, context: Context) {
      guard context.coordinator.loadedURL != url else { return }
      context.coordinator.loadedURL = url
      webView.loadHTMLString(html, baseURL: URL(string: "https://cdn.dashjs.org/"))
    }

    final class Coordinator {
      var loadedURL: URL?
    }

    private var html: String {
      let manifestURL = url.absoluteString
      return """
        <!doctype html>
        <html>
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <style>
            html, body { margin: 0; width: 100%; height: 100%; background: #000; overflow: hidden; }
            video { width: 100%; height: 100%; background: #000; object-fit: contain; }
            #status {
              position: fixed; top: 18px; right: 18px; z-index: 2;
              padding: 8px 12px; border-radius: 6px;
              font: 700 12px -apple-system, BlinkMacSystemFont, sans-serif;
              color: rgba(255,255,255,0.88); background: rgba(0,0,0,0.64);
            }
          </style>
        </head>
        <body>
          <div id="status">Tuning DASH</div>
          <video id="video" controls autoplay playsinline></video>
          <script src="https://cdn.dashjs.org/latest/dash.all.min.js"></script>
          <script>
            const status = document.getElementById('status');
            const video = document.getElementById('video');
            const player = dashjs.MediaPlayer().create();
            player.updateSettings({ streaming: { lowLatencyEnabled: true } });
            player.initialize(video, "\(manifestURL)", true);
            player.on(dashjs.MediaPlayer.events.PLAYBACK_PLAYING, () => { status.style.display = 'none'; });
            player.on(dashjs.MediaPlayer.events.ERROR, () => { status.textContent = 'DASH playback error'; });
          </script>
        </body>
        </html>
        """
    }
  }
#endif

private struct DASHUnsupportedSurface: View {
  var body: some View {
    VStack(spacing: 12) {
      Image(systemName: "display.trianglebadge.exclamationmark")
        .font(.system(size: 52, weight: .semibold))

      Text("DASH playback is macOS-only for now")
        .font(.title2.weight(.bold))

      Text(
        "This source needs a web-based MPEG-DASH player, which is not part of the tvOS native player path."
      )
      .font(.callout.weight(.medium))
      .foregroundStyle(.white.opacity(0.68))
      .multilineTextAlignment(.center)
      .frame(maxWidth: 460)
    }
    .foregroundStyle(.white)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.black)
  }
}

struct PlatformVideoPlayer: View {
  let player: AVPlayer

  var body: some View {
    #if os(macOS)
      MacVideoPlayer(player: player)
    #else
      VideoPlayer(player: player)
    #endif
  }
}

#if os(macOS)
  private struct MacVideoPlayer: NSViewRepresentable {
    let player: AVPlayer

    func makeNSView(context: Context) -> AVPlayerView {
      let view = AVPlayerView()
      view.controlsStyle = .floating
      view.player = player
      return view
    }

    func updateNSView(_ view: AVPlayerView, context: Context) {
      if view.player !== player {
        view.player = player
      }
    }
  }
#endif
