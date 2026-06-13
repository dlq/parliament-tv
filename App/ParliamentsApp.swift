//
//  ParliamentsApp.swift
//  Parliaments
//
//  Created by Darcy Quesnel on 2026-05-12.
//

import SwiftUI

@main
struct ParliamentsApp: App {
  var body: some Scene {
    #if os(macOS)
      mainWindow
        .windowStyle(.hiddenTitleBar)
        .commands {
          ChannelMenuCommands()
        }
    #else
      mainWindow
    #endif
  }

  private var mainWindow: some Scene {
    WindowGroup {
      if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil {
        ContentView()
      } else {
        Color.clear
      }
    }
  }
}

#if os(macOS)
  private struct ChannelMenuCommands: Commands {
    @FocusedValue(\.channelCommands) private var channelCommands

    var body: some Commands {
      CommandMenu("Channel") {
        Button("Show Guide") {
          channelCommands?.showGuide()
        }
        .keyboardShortcut("g", modifiers: [.command])
        .disabled(channelCommands == nil)

        Divider()

        Button("Previous Channel") {
          channelCommands?.selectPreviousChannel()
        }
        .keyboardShortcut("[", modifiers: [.command])
        .disabled(channelCommands == nil)

        Button("Next Channel") {
          channelCommands?.selectNextChannel()
        }
        .keyboardShortcut("]", modifiers: [.command])
        .disabled(channelCommands == nil)

        Divider()

        Button(channelCommands?.isCurrentChannelPinned == true ? "Unpin Channel" : "Pin Channel") {
          channelCommands?.togglePin()
        }
        .keyboardShortcut("p", modifiers: [.command])
        .disabled(channelCommands == nil)
      }
    }
  }

  struct ChannelCommands {
    let showGuide: () -> Void
    let selectPreviousChannel: () -> Void
    let selectNextChannel: () -> Void
    let togglePin: () -> Void
    let isCurrentChannelPinned: Bool
  }

  private struct ChannelCommandsKey: FocusedValueKey {
    typealias Value = ChannelCommands
  }

  extension FocusedValues {
    var channelCommands: ChannelCommands? {
      get { self[ChannelCommandsKey.self] }
      set { self[ChannelCommandsKey.self] = newValue }
    }
  }
#endif
