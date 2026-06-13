//
//  LinkOutSurface.swift
//  Parliaments
//
//  Created by Codex on 2026-06-13.
//

import SwiftUI

#if os(macOS)
  import WebKit
#endif

struct LinkOutSurface: View {
  let channel: Channel
  @Binding var isShowingInAppSource: Bool
  let openSource: () -> Void

  var body: some View {
    ZStack {
      GeometryReader { proxy in
        ViewThatFits(in: .horizontal) {
          HStack(alignment: .center, spacing: 42) {
            previewCard
              .frame(width: min(proxy.size.width * 0.52, 820))

            details
              .frame(maxWidth: 480, alignment: .leading)
          }

          VStack(alignment: .leading, spacing: 24) {
            previewCard
            details
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(44)
        .background(background)
      }

      if isShowingInAppSource {
        InAppSourceOverlay(channel: channel) {
          isShowingInAppSource = false
        }
        .transition(.opacity)
      }
    }
    .animation(.easeInOut(duration: 0.18), value: isShowingInAppSource)
  }

  private var previewCard: some View {
    Button(action: openSource) {
      ZStack {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
          .fill(previewGradient)
          .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
              .stroke(.white.opacity(0.14), lineWidth: 1)
          }

        if let previewAssetName = channel.previewAssetName {
          Image(previewAssetName)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .overlay(.black.opacity(0.28))
        }

        VStack(alignment: .leading) {
          HStack {
            Text(channel.shortName)
              .font(.headline.weight(.heavy))
              .foregroundStyle(.white.opacity(0.92))
              .lineLimit(1)

            Spacer()
          }

          Spacer()

          ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
              .fill(playButtonColor)
              .frame(width: 94, height: 66)
              .shadow(color: .black.opacity(0.26), radius: 18, y: 8)

            Image(systemName: "play.fill")
              .font(.system(size: 30, weight: .heavy))
              .foregroundStyle(.white)
              .offset(x: 2)
          }
          .frame(maxWidth: .infinity)

          Spacer()

          Text(channel.name)
            .font(.title2.weight(.bold))
            .foregroundStyle(.white)
            .lineLimit(2)

          Text(openHint)
            .font(.callout.weight(.semibold))
            .foregroundStyle(.white.opacity(0.66))
        }
        .padding(24)
      }
      .aspectRatio(16.0 / 9.0, contentMode: .fit)
      .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
    .buttonStyle(.plain)
    .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    .help(L10n.string("web.action.openOfficialSource"))
  }

  private var details: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(title)
        .font(.largeTitle.bold())
        .foregroundStyle(.white)
        .lineLimit(2)
        .fixedSize(horizontal: false, vertical: true)

      Text(channel.attributionText)
        .font(.title3.weight(.semibold))
        .foregroundStyle(.white.opacity(0.76))
        .fixedSize(horizontal: false, vertical: true)

      Button(action: openSource) {
        Label(buttonTitle, systemImage: "arrow.up.forward")
          .font(.headline)
      }
      .buttonStyle(.borderedProminent)
      .tint(playButtonColor)
      .padding(.top, 4)

      if channel.sourceType == .youtube {
        inAppWebButton
      }
    }
  }

  @ViewBuilder
  private var inAppWebButton: some View {
    #if os(macOS)
      Button {
        isShowingInAppSource = true
      } label: {
        Label(L10n.string("web.action.tryInApp"), systemImage: "rectangle.connected.to.line.below")
          .font(.headline)
      }
      .buttonStyle(.bordered)
      .tint(.white)
      .help(L10n.string("web.action.tryInApp"))
    #endif
  }

  private var title: String {
    channel.sourceType == .youtube
      ? L10n.string("web.action.openOnYouTube") : L10n.string("web.action.openSource")
  }

  private var buttonTitle: String {
    channel.sourceType == .youtube
      ? L10n.string("web.action.openOnYouTube") : L10n.string("web.action.openOfficialSource")
  }

  private var openHint: String {
    channel.sourceType == .youtube
      ? L10n.string("web.hint.launchChannelPage") : L10n.string("web.hint.launchExternalSource")
  }

  private var playButtonColor: Color {
    channel.sourceType == .youtube ? Color(red: 1.0, green: 0.0, blue: 0.0) : .blue
  }

  private var previewGradient: LinearGradient {
    LinearGradient(
      colors: [
        Color(red: 0.12, green: 0.13, blue: 0.15),
        Color(red: 0.06, green: 0.07, blue: 0.09),
      ],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }

  private var background: LinearGradient {
    LinearGradient(
      colors: [
        Color(red: 0.05, green: 0.06, blue: 0.07),
        Color(red: 0.09, green: 0.12, blue: 0.14),
      ],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }
}

private struct InAppSourceOverlay: View {
  let channel: Channel
  let close: () -> Void

  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 12) {
        Text(channel.name)
          .font(.headline.weight(.bold))
          .foregroundStyle(.white)
          .lineLimit(1)

        Text(L10n.string("web.inApp.experimental"))
          .font(.caption.weight(.bold))
          .foregroundStyle(.white.opacity(0.62))

        Spacer()

        Button(action: close) {
          Label(L10n.string("web.action.close"), systemImage: "xmark")
            .labelStyle(.iconOnly)
        }
        .buttonStyle(.plain)
        .font(.headline.weight(.bold))
        .foregroundStyle(.white.opacity(0.82))
        .padding(9)
        .background(.white.opacity(0.12), in: Circle())
        .help(L10n.string("web.action.close"))
      }
      .padding(.horizontal, 18)
      .padding(.vertical, 12)
      .background(.black.opacity(0.88))

      PlatformWebSourceView(url: channel.officialURL)
    }
    .background(.black)
  }
}

private struct PlatformWebSourceView: View {
  let url: URL

  var body: some View {
    #if os(macOS)
      MacWebSourceView(url: url)
    #else
      WebSourceUnsupportedSurface()
    #endif
  }
}

#if os(macOS)
  private struct MacWebSourceView: NSViewRepresentable {
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
      webView.load(URLRequest(url: url))
    }

    final class Coordinator {
      var loadedURL: URL?
    }
  }
#endif

private struct WebSourceUnsupportedSurface: View {
  var body: some View {
    VStack(spacing: 10) {
      Image(systemName: "safari")
        .font(.system(size: 44, weight: .semibold))

      Text(L10n.string("web.inApp.unsupported"))
        .font(.title3.weight(.bold))
    }
    .foregroundStyle(.white)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.black)
  }
}
