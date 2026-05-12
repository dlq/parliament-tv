//
//  ContentView.swift
//  Parliaments
//
//  Created by Darcy Quesnel on 2026-05-12.
//

import SwiftUI

struct ContentView: View {
    private let channels = ChannelCatalog.channels

    @State private var selectedChannelID = ChannelCatalog.channels[0].id
    @State private var isChromeVisible = true
    @State private var chromeDismissID = UUID()
    @FocusState private var focusedChannelID: String?

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
        ZStack(alignment: .topTrailing) {
            SourceBadge(channel: selectedChannel, isCompact: !isChromeVisible)

            if isChromeVisible {
                VStack(alignment: .leading, spacing: 0) {
                    TopChrome(channel: selectedChannel, channelCount: channels.count)

                    Spacer()

                    NowPlayingOverlay(channel: selectedChannel)
                        .frame(maxWidth: 760, alignment: .leading)

                    HorizontalGuide(
                        channels: channels,
                        selectedChannelID: $selectedChannelID,
                        focusedChannelID: $focusedChannelID
                    )
                    .padding(.top, 22)
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: 0.22), value: isChromeVisible)
    }

    private var compactOverlay: some View {
        ZStack(alignment: .topTrailing) {
            SourceBadge(channel: selectedChannel, isCompact: !isChromeVisible)

            if isChromeVisible {
                VStack(alignment: .leading, spacing: 14) {
                    TopChrome(channel: selectedChannel, channelCount: channels.count)

                    Spacer(minLength: 180)

                    NowPlayingOverlay(channel: selectedChannel)

                    HorizontalGuide(
                        channels: channels,
                        selectedChannelID: $selectedChannelID,
                        focusedChannelID: $focusedChannelID
                    )
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: 0.22), value: isChromeVisible)
    }

    private func selectNextChannel() {
        guard let index = channels.firstIndex(where: { $0.id == selectedChannelID }) else { return }
        selectedChannelID = channels[channels.index(afterWrapping: index)].id
        focusedChannelID = selectedChannelID
        showChromeTemporarily()
    }

    private func selectPreviousChannel() {
        guard let index = channels.firstIndex(where: { $0.id == selectedChannelID }) else { return }
        selectedChannelID = channels[channels.index(beforeWrapping: index)].id
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

private struct TopChrome: View {
    let channel: Channel
    let channelCount: Int

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Parliaments")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)

                Text("\(channelCount) native sources")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.58))
            }

            Spacer()

            SourceBadge(channel: channel, isCompact: false)
        }
    }
}

private struct NowPlayingOverlay: View {
    let channel: Channel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Text(channel.shortName)
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(.white, in: RoundedRectangle(cornerRadius: 5))

                Text(channel.availability.label)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.88))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 5))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(channel.name)
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text(channel.program.currentEventTitle)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.78))
                    .lineLimit(1)

                Text(channel.program.currentEventTime)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.white.opacity(0.58))
                    .lineLimit(1)
            }
        }
        .shadow(color: .black.opacity(0.45), radius: 12, y: 5)
    }
}

private struct HorizontalGuide: View {
    let channels: [Channel]
    @Binding var selectedChannelID: String
    var focusedChannelID: FocusState<String?>.Binding

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 10) {
                    ForEach(channels) { channel in
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
            .frame(height: 120)
            .onChange(of: selectedChannelID) { _, newValue in
                withAnimation(.snappy(duration: 0.22)) {
                    proxy.scrollTo(newValue, anchor: .center)
                }
            }
        }
    }
}

private struct GuideChannelCard: View {
    let channel: Channel
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(channel.shortName)
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
                    .font(.caption.weight(.bold))
                    .foregroundStyle(isSelected ? .black : .white)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(height: 17, alignment: .leading)

                Text(channel.program.currentEventTitle)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(isSelected ? .black.opacity(0.66) : .white.opacity(0.62))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(height: 15, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(channel.countryOrRegion)
                .font(.caption2.weight(.bold))
                .foregroundStyle(isSelected ? .black.opacity(0.58) : .white.opacity(0.46))
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(height: 14, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .frame(width: 218, height: 108, alignment: .topLeading)
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
        switch channel.availability {
        case .alwaysOn:
            "dot.radiowaves.left.and.right"
        case .sittingOnly, .eventBased:
            "calendar"
        case .unknown:
            "questionmark.circle"
        }
    }
}

private struct SourceBadge: View {
    let channel: Channel
    let isCompact: Bool

    var body: some View {
        Group {
            if isCompact {
                HStack(spacing: 7) {
                    Image(systemName: "checkmark.seal")
                    Text(channel.shortName)
                }
                .font(.caption.weight(.bold))
            } else {
                VStack(alignment: .trailing, spacing: 6) {
                    Label(sourceLabel, systemImage: "checkmark.seal")
                        .font(.caption.weight(.bold))

                    Text(channel.legalReviewStatus)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.50))
                        .lineLimit(1)
                }
            }
        }
        .foregroundStyle(.white.opacity(0.86))
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(.black.opacity(0.44), in: RoundedRectangle(cornerRadius: 7))
        .animation(.easeInOut(duration: 0.20), value: isCompact)
    }

    private var sourceLabel: String {
        switch channel.technicalStatus {
        case .validated:
            channel.sourceType == .directHLS ? "Official HLS" : channel.technicalStatus.label
        case .linkOnly, .needsReview:
            channel.technicalStatus.label
        }
    }
}

private struct VideoScrim: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.black.opacity(0.58), .clear, .black.opacity(0.64)],
                startPoint: .leading,
                endPoint: .trailing
            )

            LinearGradient(
                colors: [.black.opacity(0.52), .clear, .black.opacity(0.78)],
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
