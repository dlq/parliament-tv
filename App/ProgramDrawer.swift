//
//  ProgramDrawer.swift
//  Parliaments
//
//  Created by Codex on 2026-06-12.
//

import SwiftUI

struct ProgramDrawer: View {
    let channel: Channel
    let channelCount: Int
    let groups: [GuideGroup]
    @Binding var selectedGroupID: String
    @Binding var selectedChannelID: String
    let isChannelPinned: Bool
    let togglePin: () -> Void
    let dismissGuide: () -> Void
    var focusedChannelID: FocusState<String?>.Binding
    var density: ProgramDrawerDensity = .regular

    var body: some View {
        VStack(alignment: .leading, spacing: density.outerSpacing) {
            Button(action: dismissGuide) {
                Capsule()
                    .fill(.white.opacity(0.34))
                    .frame(width: density.handleWidth, height: density.handleHeight)
                    .frame(width: 104, height: density.handleTapHeight)
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

                if density == .regular {
                    Label(channel.sourceQualityLabel, systemImage: "checkmark.seal")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.74))
                }

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

            VStack(alignment: .leading, spacing: density.contentSpacing) {
                summary
                guide
            }
        }
        .padding(.horizontal, density.horizontalPadding)
        .padding(.top, density.topPadding)
        .padding(.bottom, density.bottomPadding)
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

    private var summary: some View {
        Group {
            if density == .compactLandscape {
                NowPlayingOverlay(channel: channel, showsDetails: false, density: density)
                    .frame(maxWidth: 620, alignment: .leading)
            } else {
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .bottom, spacing: 34) {
                        NowPlayingOverlay(channel: channel, showsDetails: false, density: density)
                            .frame(maxWidth: 640, alignment: .leading)

                        Spacer(minLength: 24)

                        MiniGuideDetails(channel: channel, density: density)
                            .frame(maxWidth: 560, alignment: .trailing)
                    }

                    NowPlayingOverlay(channel: channel, showsDetails: true, density: density)
                        .frame(maxWidth: 620, alignment: .leading)
                }
            }
        }
    }

    private var guide: some View {
        HorizontalGuide(
            groups: groups,
            selectedGroupID: $selectedGroupID,
            selectedChannelID: $selectedChannelID,
            focusedChannelID: focusedChannelID,
            density: density
        )
    }
}

enum ProgramDrawerDensity {
    case regular
    case compactLandscape

    var outerSpacing: CGFloat { self == .regular ? 18 : 8 }
    var contentSpacing: CGFloat { self == .regular ? 18 : 8 }
    var horizontalPadding: CGFloat { self == .regular ? 26 : 14 }
    var topPadding: CGFloat { self == .regular ? 20 : 8 }
    var bottomPadding: CGFloat { self == .regular ? 24 : 10 }
    var handleWidth: CGFloat { self == .regular ? 66 : 54 }
    var handleHeight: CGFloat { self == .regular ? 6 : 5 }
    var handleTapHeight: CGFloat { self == .regular ? 24 : 16 }
    var titleSize: CGFloat { self == .regular ? 38 : 22 }
    var titleLineLimit: Int { self == .regular ? 2 : 1 }
    var guideHeight: CGFloat { self == .regular ? 116 : 68 }
    var cardWidth: CGFloat { self == .regular ? 270 : 176 }
    var cardHeight: CGFloat { self == .regular ? 98 : 58 }
    var cardHorizontalPadding: CGFloat { self == .regular ? 14 : 10 }
    var cardVerticalPadding: CGFloat { self == .regular ? 12 : 8 }
}

private struct NowPlayingOverlay: View {
    let channel: Channel
    var showsDetails = true
    var density: ProgramDrawerDensity = .regular

    var body: some View {
        VStack(alignment: .leading, spacing: density == .regular ? 14 : 5) {
            VStack(alignment: .leading, spacing: density == .regular ? 8 : 5) {
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 10) {
                        ChannelCodePill(channel: channel)
                        LiveStatePill(channel: channel)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        ChannelCodePill(channel: channel)
                        LiveStatePill(channel: channel)
                    }
                }

                Text(channel.name)
                    .font(.system(size: density.titleSize, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(density.titleLineLimit)
                    .fixedSize(horizontal: false, vertical: true)

                Text(channel.program.currentEventTitle)
                    .font((density == .regular ? Font.title3 : Font.callout).weight(.semibold))
                    .foregroundStyle(.white.opacity(0.78))
                    .lineLimit(density == .regular ? 2 : 1)
                    .fixedSize(horizontal: false, vertical: true)

                if density == .regular {
                    Text(channel.program.currentEventTime)
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.white.opacity(0.58))
                        .lineLimit(1)
                }
            }

            if showsDetails {
                MiniGuideDetails(channel: channel, density: density)
            }
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

private struct MiniGuideDetails: View {
    let channel: Channel
    var density: ProgramDrawerDensity = .regular

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: 18) {
                HStack(alignment: .top, spacing: 18) {
                    MiniGuideItem(title: "Now", value: channel.program.currentEventTitle)

                    if let nextEventTitle = channel.program.nextEventTitle {
                        MiniGuideItem(title: "Next", value: nextEventTitle)
                    }
                }

                Spacer(minLength: 18)

                MiniGuideItem(title: "Audio", value: channel.language, alignment: .trailing, maxWidth: 150)
            }

            VStack(alignment: .leading, spacing: 10) {
                MiniGuideItem(title: "Now", value: channel.program.currentEventTitle, maxWidth: 460)

                if let nextEventTitle = channel.program.nextEventTitle {
                    MiniGuideItem(title: "Next", value: nextEventTitle, maxWidth: 460)
                }

                MiniGuideItem(title: "Audio", value: channel.language, maxWidth: 460)
            }
        }
    }
}

private struct MiniGuideItem: View {
    let title: String
    let value: String
    var alignment: HorizontalAlignment = .leading
    var maxWidth: CGFloat = 220

    var body: some View {
        VStack(alignment: alignment, spacing: 3) {
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
        .frame(maxWidth: maxWidth, alignment: frameAlignment)
    }

    private var frameAlignment: Alignment {
        alignment == .trailing ? .trailing : .leading
    }
}

private struct HorizontalGuide: View {
    let groups: [GuideGroup]
    @Binding var selectedGroupID: String
    @Binding var selectedChannelID: String
    var focusedChannelID: FocusState<String?>.Binding
    var density: ProgramDrawerDensity = .regular

    private var selectedGroup: GuideGroup {
        groups.first { $0.id == selectedGroupID } ?? groups[0]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            GuideGroupPicker(
                groups: groups,
                selectedGroupID: $selectedGroupID,
                selectedChannelID: $selectedChannelID,
                focusedChannelID: focusedChannelID,
                density: density
            )

            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    LazyHStack(spacing: density == .regular ? 12 : 8) {
                        ForEach(selectedGroup.channels) { channel in
                            GuideChannelCard(
                                channel: channel,
                                isSelected: channel.id == selectedChannelID,
                                density: density
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
                .frame(height: density.guideHeight)
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
    var density: ProgramDrawerDensity = .regular

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: density == .regular ? 8 : 6) {
                ForEach(groups) { group in
                    GuideGroupPill(group: group, isSelected: group.id == selectedGroupID, density: density)
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
    var density: ProgramDrawerDensity = .regular

    var body: some View {
        HStack(spacing: density == .regular ? 7 : 5) {
            Image(systemName: group.systemImage)
                .font((density == .regular ? Font.caption : Font.caption2).weight(.bold))

            Text(group.title)
                .font((density == .regular ? Font.caption : Font.caption2).weight(.heavy))

            Text(group.countLabel)
                .font(.caption2.weight(.heavy))
                .foregroundStyle(isSelected ? .black.opacity(0.62) : .white.opacity(0.50))
        }
        .foregroundStyle(isSelected ? .black : .white.opacity(0.84))
        .padding(.horizontal, density == .regular ? 12 : 9)
        .padding(.vertical, density == .regular ? 8 : 6)
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
    var density: ProgramDrawerDensity = .regular

    var body: some View {
        VStack(alignment: .leading, spacing: density == .regular ? 8 : 5) {
            HStack {
                Text(channel.channelCode)
                    .font((density == .regular ? Font.headline : Font.callout).weight(.heavy))
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
                    .font((density == .regular ? Font.callout : Font.caption).weight(.bold))
                    .foregroundStyle(isSelected ? .black : .white)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text(channel.program.currentEventTitle)
                    .font((density == .regular ? Font.caption : Font.caption2).weight(.medium))
                    .foregroundStyle(isSelected ? .black.opacity(0.66) : .white.opacity(0.62))
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, density.cardHorizontalPadding)
        .padding(.vertical, density.cardVerticalPadding)
        .frame(width: density.cardWidth, height: density.cardHeight, alignment: .topLeading)
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
