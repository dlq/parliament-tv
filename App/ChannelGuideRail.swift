//
//  ChannelGuideRail.swift
//  Parliaments
//
//  Created by Codex on 2026-06-13.
//

import SwiftUI

struct HorizontalGuide: View {
  let groups: [GuideGroup]
  @Binding var selectedGroupID: String
  let selectedChannelID: String
  let selectChannel: (Channel) -> Void
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
        selectedChannelID: selectedChannelID,
        selectChannel: selectChannel,
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
                selectChannel(channel)
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
  let selectedChannelID: String
  let selectChannel: (Channel) -> Void
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
                selectChannel(firstChannel)
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

        Image(systemName: channel.liveStateIcon)
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
}
