import SwiftUI

struct ContentView: View {
  private let nativeChannels = ChannelCatalog.channels
  private let externalChannels = ChannelCatalog.sourcesRequiringExternalPlayer

  @State private var selectedChannelID = ChannelCatalog.channels[0].id
  @State private var selectedGuideGroupID = GuideGroup.pinnedID
  @State private var isChromeVisible = true
  @State private var chromeVisibilityReason: ChromeVisibilityReason = .explicit
  @State private var transientChromeHideTask: Task<Void, Never>?
  @State private var isInAppWebOverlayVisible = false
  @StateObject private var programMetadataStore = ProgramMetadataStore()
  @AppStorage("pinnedChannelIDs") private var pinnedChannelIDsStorage = GuideGroup
    .defaultPinnedChannelIDs.joined(separator: ",")
  @FocusState private var focusedChannelID: String?

  private var channels: [Channel] {
    guideGroups.flatMap(\.channels).uniquedByID()
  }

  private var nativeSurfChannels: [Channel] {
    guideGroups
      .filter { $0.id != GuideGroup.youtubeID }
      .flatMap(\.channels)
      .filter { $0.displayMode == .nativePlayer }
      .uniquedByID()
  }

  private var guideGroups: [GuideGroup] {
    GuideGroup.build(
      nativeChannels: nativeChannels, externalChannels: externalChannels,
      pinnedChannelIDs: pinnedChannelIDs)
  }

  private var selectedGuideGroup: GuideGroup {
    guideGroups.first { $0.id == selectedGuideGroupID } ?? guideGroups[0]
  }

  private var selectedChannel: Channel {
    let channel = channels.first { $0.id == selectedChannelID } ?? channels[0]
    if let program = programMetadataStore.metadataByChannelID[channel.id] {
      return channel.replacingProgram(program)
    }
    return channel
  }

  private var pinnedChannelIDs: Set<String> {
    Set(
      pinnedChannelIDsStorage
        .split(separator: ",")
        .map(String.init)
        .filter { !$0.isEmpty }
    )
  }

  private var isSelectedChannelPinned: Bool {
    pinnedChannelIDs.contains(selectedChannelID)
  }

  var body: some View {
    GeometryReader { proxy in
      let isCompact = proxy.size.width < 760
      let isPhoneLandscape = proxy.size.width < 1000 && proxy.size.height < 500

      ZStack {
        PlayerSurface(
          channel: selectedChannel,
          style: .fullBleed,
          isInAppWebOverlayVisible: $isInAppWebOverlayVisible
        )
        .channelSwipeNavigation(
          previous: selectPreviousChannel,
          next: selectNextChannel
        )
        .ignoresSafeArea()

        if isChromeVisible {
          VideoScrim()
            .ignoresSafeArea()
            .transition(.opacity)
        }

        if isPhoneLandscape || isCompact {
          compactOverlay(density: isPhoneLandscape ? .compactLandscape : .regular)
            .padding(isPhoneLandscape ? 10 : 16)
        } else {
          tvOverlay
            .padding(.horizontal, 46)
            .padding(.vertical, 34)
        }

        macOSPointerActionOverlay
        touchActionOverlay
      }
    }
    .remoteChannelNavigation(
      previous: selectPreviousChannel,
      next: selectNextChannel
    )
    .macOSChannelCommands(
      showGuide: showChromeTemporarily,
      previous: selectPreviousChannel,
      next: selectNextChannel,
      togglePin: toggleSelectedChannelPin,
      isCurrentChannelPinned: isSelectedChannelPinned
    )
    .macOSPlayerWindow()
    .onAppear {
      reconcileGuideSelection()
    }
    .onChange(of: pinnedChannelIDsStorage) { _, _ in
      reconcileGuideSelection()
    }
    .task {
      await programMetadataStore.refresh(channels: channels, selectedChannel: selectedChannel)
    }
    .task(id: selectedChannelID) {
      await programMetadataStore.refreshSelectedChannel(selectedChannel)
    }
  }

  private var tvOverlay: some View {
    VStack {
      Spacer()

      if isChromeVisible {
        ProgramDrawer(
          channel: selectedChannel,
          channelCount: nativeChannels.count,
          groups: guideGroups,
          selectedGroupID: $selectedGuideGroupID,
          selectedChannelID: selectedChannelID,
          isChannelPinned: isSelectedChannelPinned,
          selectChannel: selectChannelFromGuide,
          togglePin: toggleSelectedChannelPin,
          dismissGuide: hideChrome,
          focusedChannelID: $focusedChannelID
        )
        .transition(.opacity.combined(with: .move(edge: .bottom)))
      }
    }
    .animation(.easeInOut(duration: 0.22), value: isChromeVisible)
  }

  private func compactOverlay(density: ProgramDrawerDensity) -> some View {
    VStack {
      Spacer()

      if isChromeVisible {
        ProgramDrawer(
          channel: selectedChannel,
          channelCount: nativeChannels.count,
          groups: guideGroups,
          selectedGroupID: $selectedGuideGroupID,
          selectedChannelID: selectedChannelID,
          isChannelPinned: isSelectedChannelPinned,
          selectChannel: selectChannelFromGuide,
          togglePin: toggleSelectedChannelPin,
          dismissGuide: hideChrome,
          focusedChannelID: $focusedChannelID,
          density: density
        )
        .transition(.opacity.combined(with: .move(edge: .bottom)))
      }
    }
    .animation(.easeInOut(duration: 0.22), value: isChromeVisible)
  }

  @ViewBuilder
  private var macOSPointerActionOverlay: some View {
    #if os(macOS)
      MacPointerActionOverlay(
        isGuideVisible: isChromeVisible || isInAppWebOverlayVisible,
        showGuide: showChromeTemporarily,
        previous: selectPreviousChannel,
        next: selectNextChannel
      )
    #endif
  }

  @ViewBuilder
  private var touchActionOverlay: some View {
    #if os(iOS)
      TouchActionOverlay(
        isGuideVisible: isChromeVisible || isInAppWebOverlayVisible,
        showGuide: showChromeTemporarily,
        previous: selectPreviousChannel,
        next: selectNextChannel
      )
    #endif
  }

  private func selectNextChannel() {
    selectAdjacentChannel(direction: .next)
  }

  private func selectPreviousChannel() {
    selectAdjacentChannel(direction: .previous)
  }

  private func selectAdjacentChannel(direction: ChannelNavigationDirection) {
    let groupChannels =
      selectedGuideGroup.id == GuideGroup.youtubeID
      ? selectedGuideGroup.channels : nativeSurfChannels
    guard let index = groupChannels.firstIndex(where: { $0.id == selectedChannelID }) else {
      selectChannelFromSurf(groupChannels[0])
      return
    }

    let nextIndex =
      switch direction {
      case .next:
        groupChannels.index(afterWrapping: index)
      case .previous:
        groupChannels.index(beforeWrapping: index)
      }

    selectChannelFromSurf(groupChannels[nextIndex])
  }

  private func selectChannelFromGuide(_ channel: Channel) {
    selectChannel(channel, shouldKeepGuideOpen: true)
  }

  private func selectChannelFromSurf(_ channel: Channel) {
    let shouldKeepGuideOpen = isChromeVisible && chromeVisibilityReason == .explicit
    selectChannel(channel, shouldKeepGuideOpen: shouldKeepGuideOpen)
  }

  private func selectChannel(_ channel: Channel, shouldKeepGuideOpen: Bool) {
    isInAppWebOverlayVisible = false
    selectedChannelID = channel.id
    if !selectedGuideGroup.channels.contains(channel) {
      selectedGuideGroupID =
        guideGroups.first { $0.channels.contains(channel) }?.id ?? selectedGuideGroupID
    }
    focusedChannelID = selectedChannelID

    if shouldKeepGuideOpen {
      showGuide()
    } else {
      showChromeForSurfing()
    }
  }

  private func reconcileGuideSelection() {
    guard
      !selectedGuideGroup.channels.contains(where: { $0.id == selectedChannelID }),
      let selectedChannelGroup = guideGroups.first(where: { group in
        group.channels.contains { $0.id == selectedChannelID }
      })
    else {
      return
    }

    selectedGuideGroupID = selectedChannelGroup.id
  }

  private func showChromeTemporarily() {
    showGuide()
  }

  private func showGuide() {
    transientChromeHideTask?.cancel()
    transientChromeHideTask = nil
    chromeVisibilityReason = .explicit
    isChromeVisible = true
  }

  private func showChromeForSurfing() {
    transientChromeHideTask?.cancel()
    chromeVisibilityReason = .channelSurf
    isChromeVisible = true

    transientChromeHideTask = Task {
      try? await Task.sleep(for: .seconds(2.4))
      guard !Task.isCancelled else { return }

      await MainActor.run {
        guard chromeVisibilityReason == .channelSurf else { return }
        isChromeVisible = false
        transientChromeHideTask = nil
      }
    }
  }

  private func hideChrome() {
    transientChromeHideTask?.cancel()
    transientChromeHideTask = nil
    isChromeVisible = false
  }

  private func toggleSelectedChannelPin() {
    guard selectedChannel.displayMode == .nativePlayer else { return }

    var updatedPinnedIDs = pinnedChannelIDs
    if updatedPinnedIDs.contains(selectedChannelID) {
      updatedPinnedIDs.remove(selectedChannelID)
    } else {
      updatedPinnedIDs.insert(selectedChannelID)
    }

    pinnedChannelIDsStorage =
      nativeChannels
      .map(\.id)
      .filter { updatedPinnedIDs.contains($0) }
      .joined(separator: ",")
    showChromeTemporarily()
  }
}

#Preview {
  ContentView()
}

private enum ChromeVisibilityReason {
  case explicit
  case channelSurf
}

private enum ChannelNavigationDirection {
  case previous
  case next
}

private struct VideoScrim: View {
  var body: some View {
    ZStack {
      LinearGradient(
        colors: [.clear, .clear, .black.opacity(0.70)],
        startPoint: .top,
        endPoint: .bottom
      )
    }
    .allowsHitTesting(false)
  }
}
