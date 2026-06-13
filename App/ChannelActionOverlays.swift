//
//  ChannelActionOverlays.swift
//  Parliaments
//
//  Created by Codex on 2026-06-13.
//

import SwiftUI

#if os(macOS)
  struct MacPointerActionOverlay: View {
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
  struct TouchActionOverlay: View {
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
      min(max(width * 0.10, 88), 142)
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
