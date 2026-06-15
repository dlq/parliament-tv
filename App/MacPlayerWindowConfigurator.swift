import SwiftUI

#if os(macOS)
  struct MacPlayerWindowConfigurator: NSViewRepresentable {
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
