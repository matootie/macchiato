import ServiceManagement
import SwiftUI

@main
struct MacchiatoApp: App {
    @State private var caffeinateService = CaffeinateService()

    var body: some Scene {
        MenuBarExtra {
            Text("Caffeinate is \(caffeinateService.isActive ? "on" : "off")")

            Button(caffeinateService.isActive ? "Turn Off" : "Turn On") {
                caffeinateService.toggle()
            }

            Divider()

            Toggle("Launch at Login", isOn: Binding(
                get: { SMAppService.mainApp.status == .enabled },
                set: { newValue in
                    if newValue {
                        try? SMAppService.mainApp.register()
                    } else {
                        try? SMAppService.mainApp.unregister()
                    }
                }
            ))

            Divider()

            Button("About Macchiato") {
                NSApplication.shared.activate()
                NSApplication.shared.orderFrontStandardAboutPanel()
            }

            Button("Quit Macchiato") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        } label: {
            Label("Macchiato", systemImage: caffeinateService.isActive ? "cup.and.saucer.fill" : "cup.and.saucer")
        }
        .menuBarExtraStyle(.menu)
    }
}
