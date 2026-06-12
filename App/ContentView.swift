//
//  ContentView.swift
//  Parliaments
//
//  Created by Darcy Quesnel on 2026-05-12.
//

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
    @AppStorage("pinnedChannelIDs") private var pinnedChannelIDsStorage = GuideGroup.defaultPinnedChannelIDs.joined(separator: ",")
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
        GuideGroup.build(nativeChannels: nativeChannels, externalChannels: externalChannels, pinnedChannelIDs: pinnedChannelIDs)
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
            let isPhoneLandscape = proxy.size.width < 1_000 && proxy.size.height < 500

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
                    selectedChannelID: $selectedChannelID,
                    isChannelPinned: isSelectedChannelPinned,
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
                    selectedChannelID: $selectedChannelID,
                    isChannelPinned: isSelectedChannelPinned,
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
        let groupChannels = selectedGuideGroup.id == GuideGroup.youtubeID ? selectedGuideGroup.channels : nativeSurfChannels
        guard let index = groupChannels.firstIndex(where: { $0.id == selectedChannelID }) else {
            selectChannelFromSurf(groupChannels[0])
            return
        }

        let nextIndex = switch direction {
        case .next:
            groupChannels.index(afterWrapping: index)
        case .previous:
            groupChannels.index(beforeWrapping: index)
        }

        selectChannelFromSurf(groupChannels[nextIndex])
    }

    private func selectChannelFromSurf(_ channel: Channel) {
        let shouldKeepGuideOpen = isChromeVisible && chromeVisibilityReason == .explicit

        isInAppWebOverlayVisible = false
        selectedChannelID = channel.id
        if !selectedGuideGroup.channels.contains(channel) {
            selectedGuideGroupID = guideGroups.first { $0.channels.contains(channel) }?.id ?? selectedGuideGroupID
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

        pinnedChannelIDsStorage = nativeChannels
            .map(\.id)
            .filter { updatedPinnedIDs.contains($0) }
            .joined(separator: ",")
        showChromeTemporarily()
    }

}

#if os(iOS)
private extension View {
    func channelSwipeNavigation(previous: @escaping () -> Void, next: @escaping () -> Void) -> some View {
        gesture(
            DragGesture(minimumDistance: 36)
                .onEnded { value in
                    let horizontal = value.translation.width
                    let vertical = value.translation.height
                    guard abs(horizontal) > 72, abs(horizontal) > abs(vertical) * 1.35 else { return }

                    if horizontal < 0 {
                        next()
                    } else {
                        previous()
                    }
                }
        )
    }
}
#else
private extension View {
    func channelSwipeNavigation(previous: @escaping () -> Void, next: @escaping () -> Void) -> some View {
        self
    }
}
#endif

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

#if os(macOS)
private struct MacPointerActionOverlay: View {
    let isGuideVisible: Bool
    let showGuide: () -> Void
    let previous: () -> Void
    let next: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                HStack(spacing: 0) {
                    MacPointerActionHotspot(
                        title: "Previous",
                        systemImage: "chevron.left",
                        placement: .left,
                        isGuideVisible: isGuideVisible,
                        action: previous
                    )
                    .frame(width: sideWidth(for: proxy.size.width, isGuideVisible: isGuideVisible))

                    Spacer(minLength: 0)

                    MacPointerActionHotspot(
                        title: "Next",
                        systemImage: "chevron.right",
                        placement: .right,
                        isGuideVisible: isGuideVisible,
                        action: next
                    )
                    .frame(width: sideWidth(for: proxy.size.width, isGuideVisible: isGuideVisible))
                }

                VStack(spacing: 0) {
                    Spacer(minLength: 0)

                    if !isGuideVisible {
                        HStack(spacing: 0) {
                            MacPointerActionHotspot(
                                title: "Guide",
                                systemImage: "chevron.up",
                                placement: .bottom,
                                isGuideVisible: isGuideVisible,
                                action: showGuide
                            )
                            .frame(width: guideWidth(for: proxy.size.width))

                            Spacer(minLength: 0)
                        }
                        .frame(height: bottomHeight(for: proxy.size.height))
                        .transition(.opacity)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.18), value: isGuideVisible)
        }
        .ignoresSafeArea()
    }

    private func sideWidth(for width: CGFloat, isGuideVisible: Bool) -> CGFloat {
        if isGuideVisible {
            return min(max(width * 0.028, 42), 56)
        }

        return min(max(width * 0.08, 74), 128)
    }

    private func bottomHeight(for height: CGFloat) -> CGFloat {
        min(max(height * 0.12, 72), 116)
    }

    private func guideWidth(for width: CGFloat) -> CGFloat {
        min(max(width * 0.16, 178), 260)
    }
}

private struct MacPointerActionHotspot: View {
    let title: String
    let systemImage: String
    let placement: Placement
    var isGuideVisible = false
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            ZStack {
                hoverFill

                hotspotLabel
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: labelAlignment)
                    .padding(labelPadding)
            }
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.16)) {
                isHovered = hovering
            }
        }
        .help(title)
    }

    private var hoverFill: some View {
        Rectangle()
            .fill(gradient)
            .opacity(isHovered ? 1 : restingFillOpacity)
    }

    @ViewBuilder
    private var hotspotLabel: some View {
        switch placement {
        case .bottom:
            Label(title, systemImage: systemImage)
                .font(.callout.weight(.bold))
                .foregroundStyle(.white.opacity(isHovered ? 0.90 : 0.56))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.black.opacity(isHovered ? 0.34 : 0.18), in: Capsule())
        case .left, .right:
            Label(title, systemImage: systemImage)
                .font((isGuideVisible ? Font.caption : Font.callout).weight(.bold))
                .labelStyle(.iconOnly)
                .foregroundStyle(.white.opacity(sideIconOpacity))
                .padding(isGuideVisible ? 9 : 14)
                .background(.black.opacity(sideIconBackgroundOpacity), in: Circle())
        }
    }

    private var restingFillOpacity: Double {
        if placement == .bottom {
            return 0.08
        }

        return isGuideVisible ? 0.0 : 0.02
    }

    private var sideIconOpacity: Double {
        if isHovered {
            return 0.86
        }

        return isGuideVisible ? 0.38 : 0.0
    }

    private var sideIconBackgroundOpacity: Double {
        if isHovered {
            return 0.30
        }

        return isGuideVisible ? 0.16 : 0.0
    }

    private var gradient: LinearGradient {
        switch placement {
        case .left:
            LinearGradient(
                colors: [.black.opacity(0.24), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .right:
            LinearGradient(
                colors: [.clear, .black.opacity(0.24)],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .bottom:
            LinearGradient(
                colors: [.clear, .black.opacity(0.26)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private var labelAlignment: Alignment {
        switch placement {
        case .left:
            .leading
        case .right:
            .trailing
        case .bottom:
            .bottom
        }
    }

    private var labelPadding: EdgeInsets {
        switch placement {
        case .left:
            EdgeInsets(top: 0, leading: isGuideVisible ? 6 : 18, bottom: 0, trailing: 0)
        case .right:
            EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: isGuideVisible ? 6 : 18)
        case .bottom:
            EdgeInsets(top: 0, leading: 0, bottom: 18, trailing: 0)
        }
    }

    enum Placement {
        case left
        case right
        case bottom
    }
}
#endif

#if os(iOS)
private struct TouchActionOverlay: View {
    let isGuideVisible: Bool
    let showGuide: () -> Void
    let previous: () -> Void
    let next: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                HStack(spacing: 0) {
                    TouchActionHotspot(
                        title: "Previous",
                        systemImage: "chevron.left",
                        placement: .left,
                        isGuideVisible: isGuideVisible,
                        action: previous
                    )
                    .frame(width: sideWidth(for: proxy.size.width, isGuideVisible: isGuideVisible))

                    Spacer(minLength: 0)

                    TouchActionHotspot(
                        title: "Next",
                        systemImage: "chevron.right",
                        placement: .right,
                        isGuideVisible: isGuideVisible,
                        action: next
                    )
                    .frame(width: sideWidth(for: proxy.size.width, isGuideVisible: isGuideVisible))
                }

                VStack(spacing: 0) {
                    Spacer(minLength: 0)

                    if !isGuideVisible {
                        HStack(spacing: 0) {
                            TouchActionHotspot(
                                title: "Guide",
                                systemImage: "chevron.up",
                                placement: .bottom,
                                action: showGuide
                            )
                            .frame(width: guideWidth(for: proxy.size.width))

                            Spacer(minLength: 0)
                        }
                        .frame(height: bottomHeight(for: proxy.size.height))
                        .transition(.opacity)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.18), value: isGuideVisible)
        }
        .ignoresSafeArea()
    }

    private func sideWidth(for width: CGFloat, isGuideVisible: Bool) -> CGFloat {
        return min(max(width * 0.10, 88), 142)
    }

    private func bottomHeight(for height: CGFloat) -> CGFloat {
        min(max(height * 0.12, 72), 116)
    }

    private func guideWidth(for width: CGFloat) -> CGFloat {
        min(max(width * 0.20, 178), 280)
    }
}

private struct TouchActionHotspot: View {
    let title: String
    let systemImage: String
    let placement: Placement
    var isGuideVisible = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                gradient

                hotspotLabel
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: labelAlignment)
                    .padding(labelPadding)
            }
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .accessibilityLabel(title)
    }

    @ViewBuilder
    private var hotspotLabel: some View {
        switch placement {
        case .bottom:
            Label(title, systemImage: systemImage)
                .font(.callout.weight(.bold))
                .foregroundStyle(.white.opacity(0.84))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.black.opacity(0.30), in: Capsule())
        case .left, .right:
            Label(title, systemImage: systemImage)
                .font(.callout.weight(.bold))
                .labelStyle(.iconOnly)
                .foregroundStyle(.white.opacity(0.46))
                .padding(14)
                .background(.black.opacity(0.18), in: Circle())
        }
    }

    private var gradient: LinearGradient {
        switch placement {
        case .left:
            LinearGradient(
                colors: [.black.opacity(0.12), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .right:
            LinearGradient(
                colors: [.clear, .black.opacity(0.12)],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .bottom:
            LinearGradient(
                colors: [.clear, .black.opacity(0.18)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private var labelAlignment: Alignment {
        switch placement {
        case .left:
            .leading
        case .right:
            .trailing
        case .bottom:
            .bottomLeading
        }
    }

    private var labelPadding: EdgeInsets {
        switch placement {
        case .left:
            EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 0)
        case .right:
            EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 18)
        case .bottom:
            EdgeInsets(top: 0, leading: 24, bottom: 20, trailing: 0)
        }
    }

    enum Placement {
        case left
        case right
        case bottom
    }
}
#endif

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

private struct RemoteChannelNavigation: ViewModifier {
    let previous: () -> Void
    let next: () -> Void

    func body(content: Content) -> some View {
        #if os(tvOS) || os(macOS)
        content
            .onMoveCommand { direction in
                switch direction {
                case .up, .left:
                    previous()
                case .down, .right:
                    next()
                default:
                    break
                }
            }
        #else
        content
        #endif
    }
}

private extension View {
    func remoteChannelNavigation(previous: @escaping () -> Void, next: @escaping () -> Void) -> some View {
        modifier(RemoteChannelNavigation(previous: previous, next: next))
    }

    @ViewBuilder
    func macOSChannelCommands(
        showGuide: @escaping () -> Void,
        previous: @escaping () -> Void,
        next: @escaping () -> Void,
        togglePin: @escaping () -> Void,
        isCurrentChannelPinned: Bool
    ) -> some View {
        #if os(macOS)
        focusedSceneValue(\.channelCommands, ChannelCommands(
            showGuide: showGuide,
            selectPreviousChannel: previous,
            selectNextChannel: next,
            togglePin: togglePin,
            isCurrentChannelPinned: isCurrentChannelPinned
        ))
        #else
        self
        #endif
    }

    @ViewBuilder
    func macOSPlayerWindow() -> some View {
        #if os(macOS)
        background(MacPlayerWindowConfigurator())
        #else
        self
        #endif
    }
}

#if os(macOS)
private struct MacPlayerWindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.postsFrameChangedNotifications = false

        DispatchQueue.main.async {
            configure(window: view.window)
        }

        return view
    }

    func updateNSView(_ view: NSView, context: Context) {
        DispatchQueue.main.async {
            configure(window: view.window)
        }
    }

    private func configure(window: NSWindow?) {
        guard let window else { return }

        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.backgroundColor = .black
        window.contentAspectRatio = NSSize(width: 16, height: 9)

        if !window.styleMask.contains(.fullSizeContentView) {
            window.styleMask.insert(.fullSizeContentView)
        }

        window.standardWindowButton(.closeButton)?.isHidden = false
        window.standardWindowButton(.miniaturizeButton)?.isHidden = false
        window.standardWindowButton(.zoomButton)?.isHidden = false
    }
}
#endif

private extension Array {
    func index(afterWrapping index: Index) -> Index {
        let next = self.index(after: index)
        return next == endIndex ? startIndex : next
    }

    func index(beforeWrapping index: Index) -> Index {
        index == startIndex ? self.index(before: endIndex) : self.index(before: index)
    }
}

private extension Array where Element == Channel {
    func uniquedByID() -> [Channel] {
        var seenIDs = Set<String>()
        return filter { channel in
            seenIDs.insert(channel.id).inserted
        }
    }
}
