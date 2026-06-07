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
    @State private var isInAppWebOverlayVisible = false
    @State private var chromeDismissID = UUID()
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

            ZStack {
                PlayerSurface(
                    channel: selectedChannel,
                    style: .fullBleed,
                    isInAppWebOverlayVisible: $isInAppWebOverlayVisible
                )
                    .ignoresSafeArea()

                if isChromeVisible {
                    VideoScrim()
                        .ignoresSafeArea()
                        .transition(.opacity)
                }

                if isCompact {
                    compactOverlay
                        .padding(16)
                } else {
                    tvOverlay
                        .padding(.horizontal, 46)
                        .padding(.vertical, 34)
                }

                macOSPointerActionOverlay
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
            scheduleChromeDismissal()
        }
        .task {
            await programMetadataStore.refreshCPAC()
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

    private var compactOverlay: some View {
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

    private func selectNextChannel() {
        selectAdjacentChannel(direction: .next)
    }

    private func selectPreviousChannel() {
        selectAdjacentChannel(direction: .previous)
    }

    private func selectAdjacentChannel(direction: ChannelNavigationDirection) {
        let groupChannels = selectedGuideGroup.id == GuideGroup.youtubeID ? selectedGuideGroup.channels : nativeSurfChannels
        guard let index = groupChannels.firstIndex(where: { $0.id == selectedChannelID }) else {
            selectChannel(groupChannels[0])
            return
        }

        let nextIndex = switch direction {
        case .next:
            groupChannels.index(afterWrapping: index)
        case .previous:
            groupChannels.index(beforeWrapping: index)
        }

        selectChannel(groupChannels[nextIndex])
    }

    private func selectChannel(_ channel: Channel) {
        isInAppWebOverlayVisible = false
        selectedChannelID = channel.id
        if !selectedGuideGroup.channels.contains(channel) {
            selectedGuideGroupID = guideGroups.first { $0.channels.contains(channel) }?.id ?? selectedGuideGroupID
        }
        focusedChannelID = selectedChannelID
        showChromeTemporarily()
    }

    private func showChromeTemporarily() {
        isChromeVisible = true
        scheduleChromeDismissal()
    }

    private func hideChrome() {
        chromeDismissID = UUID()
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

    private func scheduleChromeDismissal() {
        let dismissID = UUID()
        chromeDismissID = dismissID

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(9))
            guard chromeDismissID == dismissID else { return }
            isChromeVisible = false
        }
    }
}

#Preview {
    ContentView()
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
                if !isGuideVisible {
                    HStack(spacing: 0) {
                        MacPointerActionHotspot(
                            title: "Previous",
                            systemImage: "chevron.left",
                            placement: .left,
                            action: previous
                        )
                        .frame(width: sideWidth(for: proxy.size.width))

                        Spacer(minLength: 0)

                        MacPointerActionHotspot(
                            title: "Next",
                            systemImage: "chevron.right",
                            placement: .right,
                            action: next
                        )
                        .frame(width: sideWidth(for: proxy.size.width))
                    }
                }

                VStack(spacing: 0) {
                    Spacer(minLength: 0)

                    if !isGuideVisible {
                        HStack(spacing: 0) {
                            MacPointerActionHotspot(
                                title: "Guide",
                                systemImage: "chevron.up",
                                placement: .bottom,
                                action: showGuide
                            )
                            .frame(maxWidth: .infinity)

                            Color.clear
                                .frame(width: playerControlsPassthroughWidth(for: proxy.size.width))
                                .allowsHitTesting(false)

                            MacPointerActionHotspot(
                                title: "Guide",
                                systemImage: "chevron.up",
                                placement: .bottom,
                                action: showGuide
                            )
                            .frame(maxWidth: .infinity)
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

    private func sideWidth(for width: CGFloat) -> CGFloat {
        min(max(width * 0.08, 74), 128)
    }

    private func bottomHeight(for height: CGFloat) -> CGFloat {
        min(max(height * 0.12, 72), 116)
    }

    private func playerControlsPassthroughWidth(for width: CGFloat) -> CGFloat {
        min(max(width * 0.36, 420), 680)
    }
}

private struct MacPointerActionHotspot: View {
    let title: String
    let systemImage: String
    let placement: Placement
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
                .font(.callout.weight(.bold))
                .labelStyle(.iconOnly)
                .foregroundStyle(.white.opacity(isHovered ? 0.86 : 0.0))
                .padding(14)
                .background(.black.opacity(isHovered ? 0.30 : 0.0), in: Circle())
        }
    }

    private var restingFillOpacity: Double {
        placement == .bottom ? 0.08 : 0.02
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
            EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 0)
        case .right:
            EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 18)
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

private struct ProgramDrawer: View {
    let channel: Channel
    let channelCount: Int
    let groups: [GuideGroup]
    @Binding var selectedGroupID: String
    @Binding var selectedChannelID: String
    let isChannelPinned: Bool
    let togglePin: () -> Void
    let dismissGuide: () -> Void
    var focusedChannelID: FocusState<String?>.Binding

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Button(action: dismissGuide) {
                Capsule()
                    .fill(.white.opacity(0.34))
                    .frame(width: 66, height: 6)
                .frame(width: 104, height: 24)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .center)
            .help("Hide guide")

            HStack(alignment: .firstTextBaseline, spacing: 14) {
                Text("Parliaments")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(.white.opacity(0.54))
                    .textCase(.uppercase)

                Text("\(channelCount) native sources")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.44))

                Spacer(minLength: 20)

                Label(channel.sourceQualityLabel, systemImage: "checkmark.seal")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.74))

                if channel.displayMode == .nativePlayer {
                    Button(action: togglePin) {
                        Label(isChannelPinned ? "Unpin channel" : "Pin channel", systemImage: isChannelPinned ? "pin.fill" : "pin")
                            .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.plain)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(isChannelPinned ? .black : .white.opacity(0.78))
                    .padding(8)
                    .background(isChannelPinned ? .white : .white.opacity(0.14), in: RoundedRectangle(cornerRadius: 6))
                    .help(isChannelPinned ? "Unpin channel" : "Pin channel")
                }
            }

            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 26) {
                    nowPlaying

                    Divider()
                        .overlay(.white.opacity(0.18))

                    guide
                }

                VStack(alignment: .leading, spacing: 18) {
                    nowPlaying
                    guide
                }
            }
        }
        .padding(.horizontal, 26)
        .padding(.top, 20)
        .padding(.bottom, 24)
        .background {
            UnevenRoundedRectangle(topLeadingRadius: 8, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 8)
                .fill(.black.opacity(0.70))
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(.white.opacity(0.10))
                        .frame(height: 1)
                }
        }
        .shadow(color: .black.opacity(0.36), radius: 22, y: -8)
    }

    private var nowPlaying: some View {
        NowPlayingOverlay(channel: channel)
            .frame(maxWidth: 520, alignment: .leading)
    }

    private var guide: some View {
        HorizontalGuide(
            groups: groups,
            selectedGroupID: $selectedGroupID,
            selectedChannelID: $selectedChannelID,
            focusedChannelID: focusedChannelID
        )
    }
}

private struct NowPlayingOverlay: View {
    let channel: Channel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 10) {
                        ChannelCodePill(channel: channel)
                        LiveStatePill(channel: channel)
                        SourceQualityPill(channel: channel)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        ChannelCodePill(channel: channel)
                        HStack(spacing: 8) {
                            LiveStatePill(channel: channel)
                            SourceQualityPill(channel: channel)
                        }
                    }
                }

                Text(channel.name)
                    .font(.system(size: 38, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(channel.program.currentEventTitle)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.78))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(channel.program.currentEventTime)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.white.opacity(0.58))
                    .lineLimit(1)
            }

            MiniGuideDetails(channel: channel)
        }
    }
}

private struct ChannelCodePill: View {
    let channel: Channel

    var body: some View {
        Text(channel.channelCode)
            .font(.headline.weight(.heavy))
            .foregroundStyle(.black)
            .lineLimit(1)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(.white, in: RoundedRectangle(cornerRadius: 5))
    }
}

private struct LiveStatePill: View {
    let channel: Channel

    var body: some View {
        Label(channel.liveStateLabel, systemImage: channel.liveStateIcon)
            .font(.caption.weight(.bold))
            .foregroundStyle(.white.opacity(0.90))
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 5))
    }
}

private struct SourceQualityPill: View {
    let channel: Channel

    var body: some View {
        Text(channel.sourceQualityLabel)
            .font(.caption.weight(.bold))
            .foregroundStyle(.white.opacity(0.78))
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(.black.opacity(0.34), in: RoundedRectangle(cornerRadius: 5))
    }
}

private struct MiniGuideDetails: View {
    let channel: Channel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            items
        }
    }

    @ViewBuilder
    private var items: some View {
        MiniGuideItem(title: "Now", value: channel.program.currentEventTitle)

        if let nextEventTitle = channel.program.nextEventTitle {
            MiniGuideItem(title: "Next", value: nextEventTitle)
        }

        MiniGuideItem(title: "Audio", value: channel.language)
    }
}

private struct MiniGuideItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption2.weight(.heavy))
                .foregroundStyle(.white.opacity(0.46))
                .textCase(.uppercase)

            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.82))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: 460, alignment: .leading)
    }
}

private struct HorizontalGuide: View {
    let groups: [GuideGroup]
    @Binding var selectedGroupID: String
    @Binding var selectedChannelID: String
    var focusedChannelID: FocusState<String?>.Binding

    private var selectedGroup: GuideGroup {
        groups.first { $0.id == selectedGroupID } ?? groups[0]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            GuideGroupPicker(
                groups: groups,
                selectedGroupID: $selectedGroupID,
                selectedChannelID: $selectedChannelID,
                focusedChannelID: focusedChannelID
            )

            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 12) {
                        ForEach(selectedGroup.channels) { channel in
                            GuideChannelCard(
                                channel: channel,
                                isSelected: channel.id == selectedChannelID
                            )
                            .focused(focusedChannelID, equals: channel.id)
                            .focusable(false)
                            .onTapGesture {
                                selectedChannelID = channel.id
                                focusedChannelID.wrappedValue = channel.id
                            }
                            .id(channel.id)
                        }
                    }
                    .padding(.horizontal, 2)
                    .padding(.vertical, 4)
                }
                .scrollIndicators(.hidden)
                .frame(height: 116)
                .onChange(of: selectedChannelID) { _, newValue in
                    withAnimation(.snappy(duration: 0.22)) {
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
                .onChange(of: selectedGroupID) { _, _ in
                    withAnimation(.snappy(duration: 0.22)) {
                        proxy.scrollTo(selectedChannelID, anchor: .center)
                    }
                }
            }
        }
    }
}

private struct GuideGroupPicker: View {
    let groups: [GuideGroup]
    @Binding var selectedGroupID: String
    @Binding var selectedChannelID: String
    var focusedChannelID: FocusState<String?>.Binding

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(groups) { group in
                    GuideGroupPill(group: group, isSelected: group.id == selectedGroupID)
                        .onTapGesture {
                            selectedGroupID = group.id
                            if let firstChannel = group.channels.first {
                                selectedChannelID = firstChannel.id
                                focusedChannelID.wrappedValue = firstChannel.id
                            }
                        }
                }
            }
            .padding(.horizontal, 2)
            .padding(.vertical, 2)
        }
        .scrollIndicators(.hidden)
    }
}

private struct GuideGroupPill: View {
    let group: GuideGroup
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: group.systemImage)
                .font(.caption.weight(.bold))

            Text(group.title)
                .font(.caption.weight(.heavy))

            Text(group.countLabel)
                .font(.caption2.weight(.heavy))
                .foregroundStyle(isSelected ? .black.opacity(0.62) : .white.opacity(0.50))
        }
        .foregroundStyle(isSelected ? .black : .white.opacity(0.84))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isSelected ? .white : .black.opacity(0.42), in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(.white.opacity(isSelected ? 0.85 : 0.12), lineWidth: 1)
        }
        .contentShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct GuideChannelCard: View {
    let channel: Channel
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(channel.channelCode)
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(isSelected ? .black : .white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Spacer()

                Image(systemName: statusIcon)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(isSelected ? .black.opacity(0.72) : .cyan)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(channel.name)
                    .font(.callout.weight(.bold))
                    .foregroundStyle(isSelected ? .black : .white)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text(channel.program.currentEventTitle)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(isSelected ? .black.opacity(0.66) : .white.opacity(0.62))
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(width: 270, height: 98, alignment: .topLeading)
        .clipped()
        .background(background, in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? .white.opacity(0.85) : .white.opacity(0.12), lineWidth: 1)
        }
        .contentShape(RoundedRectangle(cornerRadius: 8))
    }

    private var background: Color {
        isSelected ? .white : Color.black.opacity(0.46)
    }

    private var statusIcon: String {
        channel.liveStateIcon
    }
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
