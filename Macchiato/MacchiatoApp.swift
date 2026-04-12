import SwiftUI

@main
struct MacchiatoApp: App {
    var body: some Scene {
        MenuBarExtra("Macchiato", systemImage: "cup.and.saucer") {
            Button("Quit Macchiato") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .menuBarExtraStyle(.menu)
    }
}
