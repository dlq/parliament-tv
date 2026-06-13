//
//  ChannelNavigationModifiers.swift
//  Parliaments
//
//  Created by Codex on 2026-06-13.
//

import SwiftUI

#if os(iOS)
  extension View {
    func channelSwipeNavigation(
      previous: @escaping () -> Void, next: @escaping () -> Void
    ) -> some View {
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
  extension View {
    func channelSwipeNavigation(
      previous: @escaping () -> Void, next: @escaping () -> Void
    ) -> some View {
      self
    }
  }
#endif

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

extension View {
  func remoteChannelNavigation(
    previous: @escaping () -> Void, next: @escaping () -> Void
  ) -> some View {
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
      focusedSceneValue(
        \.channelCommands,
        ChannelCommands(
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
