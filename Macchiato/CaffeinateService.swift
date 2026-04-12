import AppKit
import Observation

@Observable
final class CaffeinateService {
    private(set) var isActive = false
    private var process: Process?
    private var terminationObserver: Any?

    init() {
        terminationObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.stop()
        }
    }

    deinit {
        if let terminationObserver {
            NotificationCenter.default.removeObserver(terminationObserver)
        }
        process?.terminate()
    }

    func start() {
        guard !isActive else { return }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")
        process.arguments = ["-ds"]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        process.terminationHandler = { [weak self] terminatedProcess in
            DispatchQueue.main.async {
                guard let self, self.process === terminatedProcess else { return }
                self.isActive = false
                self.process = nil
            }
        }

        do {
            try process.run()
            self.process = process
            isActive = true
        } catch {
            // caffeinate failed to launch — remain inactive
        }
    }

    func stop() {
        guard let process else {
            isActive = false
            return
        }
        self.process = nil
        isActive = false
        process.terminate()
    }

    func toggle() {
        if isActive {
            stop()
        } else {
            start()
        }
    }
}
