import AVKit
import SwiftUI

struct PlayerSurface: View {
  enum Style {
    case framed
    case fullBleed
  }

  let channel: Channel
  let style: Style
  @Binding private var isInAppWebOverlayVisible: Bool

  @Environment(\.openURL) private var openURL
  @State private var player = AVPlayer()
  @State private var signalState: SignalState = .idle
  @State private var loadID = UUID()
  @State private var currentItemObservation: NSKeyValueObservation?

  init(
    channel: Channel, style: Style = .framed,
    isInAppWebOverlayVisible: Binding<Bool> = .constant(false)
  ) {
    self.channel = channel
    self.style = style
    _isInAppWebOverlayVisible = isInAppWebOverlayVisible
  }

  var body: some View {
    ZStack(alignment: .bottomLeading) {
      surface
      signalOverlay

      if style == .framed {
        framedTitleOverlay
      }
    }
    .clipShape(RoundedRectangle(cornerRadius: style == .framed ? 8 : 0, style: .continuous))
    .overlay { borderOverlay }
    .onAppear(perform: loadPlayer)
    .onChange(of: channel.id) { _, _ in
      isInAppWebOverlayVisible = false
      loadPlayer()
    }
    .onDisappear {
      isInAppWebOverlayVisible = false
      player.pause()
    }
  }

  private var framedTitleOverlay: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(spacing: 10) {
        Text(channel.shortName)
          .font(.caption.weight(.heavy))
          .textCase(.uppercase)
          .foregroundStyle(.black)
          .padding(.horizontal, 10)
          .padding(.vertical, 6)
          .background(.white, in: RoundedRectangle(cornerRadius: 5))

        Text(channel.availability.label)
          .font(.caption.weight(.bold))
          .foregroundStyle(.white.opacity(0.86))
          .padding(.horizontal, 10)
          .padding(.vertical, 6)
          .background(.black.opacity(0.62), in: RoundedRectangle(cornerRadius: 5))
      }

      VStack(alignment: .leading, spacing: 5) {
        Text(channel.name)
          .font(.largeTitle.weight(.bold))
          .lineLimit(1)

        Text(channel.program.currentEventTitle)
          .font(.headline.weight(.semibold))
          .foregroundStyle(.white.opacity(0.74))
          .lineLimit(1)
      }
    }
    .foregroundStyle(.white)
    .shadow(radius: 8)
    .padding(26)
  }

  @ViewBuilder
  private var borderOverlay: some View {
    if style == .framed {
      RoundedRectangle(cornerRadius: 8, style: .continuous)
        .stroke(.white.opacity(0.12), lineWidth: 1)
    }
  }

  @ViewBuilder
  private var signalOverlay: some View {
    if channel.displayMode == .nativePlayer, channel.sourceType == .directHLS,
      signalState != .playing
    {
      VStack {
        HStack {
          Spacer()

          Label(signalState.label(for: channel), systemImage: signalState.systemImage)
            .font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.black.opacity(0.72), in: RoundedRectangle(cornerRadius: 5))
        }

        Spacer()
      }
      .padding(18)
    }
  }

  @ViewBuilder
  private var surface: some View {
    if channel.displayMode == .nativePlayer, channel.sourceType == .directDASH,
      let playbackURL = channel.playbackURL
    {
      PlatformDASHPlayer(url: playbackURL)
        .background(.black)
    } else if channel.displayMode == .nativePlayer, channel.playbackURL != nil {
      PlatformVideoPlayer(player: player)
        .background(.black)
    } else {
      LinkOutSurface(channel: channel, isShowingInAppSource: $isInAppWebOverlayVisible) {
        openURL(channel.officialURL)
      }
    }
  }

  private func loadPlayer() {
    guard channel.displayMode == .nativePlayer, let playbackURL = channel.playbackURL,
      channel.sourceType == .directHLS
    else {
      signalState = .idle
      loadID = UUID()
      player.pause()
      player.replaceCurrentItem(with: nil)
      return
    }

    let currentLoadID = UUID()
    loadID = currentLoadID
    signalState = .loading
    currentItemObservation = nil

    let item = AVPlayerItem(url: playbackURL)
    currentItemObservation = item.observe(\.status, options: [.initial, .new]) { [player] item, _ in
      guard item.status == .readyToPlay else { return }
      Task { @MainActor in
        signalState = .playing
      }
      player.playImmediately(atRate: 1.0)
    }

    player.replaceCurrentItem(with: item)
    player.playImmediately(atRate: 1.0)

    Task { @MainActor in
      try? await Task.sleep(for: .seconds(6))
      guard loadID == currentLoadID else { return }
      if player.timeControlStatus != .playing {
        player.playImmediately(atRate: 1.0)
      }
      try? await Task.sleep(for: .seconds(1))
      guard loadID == currentLoadID else { return }
      signalState =
        player.currentItem?.status == .readyToPlay || player.timeControlStatus == .playing
        ? .playing : .noSignal
    }
  }
}

private enum SignalState: Equatable {
  case idle
  case loading
  case playing
  case noSignal

  var systemImage: String {
    switch self {
    case .idle: "circle"
    case .loading: "antenna.radiowaves.left.and.right"
    case .playing: "play.fill"
    case .noSignal: "exclamationmark.triangle"
    }
  }

  func label(for channel: Channel) -> String {
    switch self {
    case .idle:
      L10n.string("player.signal.ready")
    case .loading:
      channel.availability == .alwaysOn
        ? L10n.string("player.signal.loading") : L10n.string("player.signal.loadingMaybeOffAir")
    case .playing:
      L10n.string("player.signal.live")
    case .noSignal:
      channel.availability == .alwaysOn
        ? L10n.string("player.signal.noSignal")
        : L10n.string("player.signal.noSignalLikelyOffAir")
    }
  }
}
