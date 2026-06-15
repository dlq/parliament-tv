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
      CommandMenu(L10n.string("menu.channel")) {
        Button(L10n.string("guide.action.show")) {
          channelCommands?.showGuide()
        }
        .keyboardShortcut("g", modifiers: [.command])
        .disabled(channelCommands == nil)

        Divider()

        Button(L10n.string("menu.channel.previous")) {
          channelCommands?.selectPreviousChannel()
        }
        .keyboardShortcut("[", modifiers: [.command])
        .disabled(channelCommands == nil)

        Button(L10n.string("menu.channel.next")) {
          channelCommands?.selectNextChannel()
        }
        .keyboardShortcut("]", modifiers: [.command])
        .disabled(channelCommands == nil)

        Divider()

        Button(
          channelCommands?.isCurrentChannelPinned == true
            ? L10n.string("menu.channel.unpin") : L10n.string("menu.channel.pin")
        ) {
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
