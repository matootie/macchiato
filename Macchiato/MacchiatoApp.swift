import SwiftUI

@main
struct MacchiatoApp: App {
    @State private var caffeinateService = CaffeinateService()

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
