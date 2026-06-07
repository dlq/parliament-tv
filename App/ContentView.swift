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
    @State private var chromeDismissID = UUID()
    @FocusState private var focusedChannelID: String?

    private var channels: [Channel] {
        guideGroups.flatMap(\.channels).uniquedByID()
    }

    private var nativeSurfChannels: [Channel] {
        guideGroups
            .filter { $0.id != GuideGroup.linkOutID }
            .flatMap(\.channels)
            .uniquedByID()
    }

    private var guideGroups: [GuideGroup] {
        GuideGroup.build(nativeChannels: nativeChannels, externalChannels: externalChannels)
    }

    private var selectedGuideGroup: GuideGroup {
        guideGroups.first { $0.id == selectedGuideGroupID } ?? guideGroups[0]
    }

    private var selectedChannel: Channel {
        channels.first { $0.id == selectedChannelID } ?? channels[0]
    }

    var body: some View {
        GeometryReader { proxy in
            let isCompact = proxy.size.width < 760

            ZStack {
                PlayerSurface(channel: selectedChannel, style: .fullBleed)
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
            }
        }
        .remoteChannelNavigation(
            previous: selectPreviousChannel,
            next: selectNextChannel
        )
        .onAppear {
            scheduleChromeDismissal()
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
                    focusedChannelID: $focusedChannelID
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: 0.22), value: isChromeVisible)
    }

    private func selectNextChannel() {
        selectAdjacentChannel(direction: .next)
    }

    private func selectPreviousChannel() {
        selectAdjacentChannel(direction: .previous)
    }

    private func selectAdjacentChannel(direction: ChannelNavigationDirection) {
        let groupChannels = selectedGuideGroup.id == GuideGroup.linkOutID ? selectedGuideGroup.channels : nativeSurfChannels
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

    private func scheduleChromeDismissal() {
        let dismissID = UUID()
        chromeDismissID = dismissID

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(5))
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

private struct ProgramDrawer: View {
    let channel: Channel
    let channelCount: Int
    let groups: [GuideGroup]
    @Binding var selectedGroupID: String
    @Binding var selectedChannelID: String
    var focusedChannelID: FocusState<String?>.Binding

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
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
}

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
