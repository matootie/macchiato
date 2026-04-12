# Macchiato — Implementation Plan

## Overview

Macchiato is a macOS menu bar app that toggles `caffeinate -ds` on and off. No dock icon, no main window — just a status item in the menu bar with a dropdown to control sleep prevention.

### Technology choices

| Decision | Choice | Rationale |
|---|---|---|
| Language | Swift | Native macOS, first-class process management, required by the platform |
| UI framework | SwiftUI + AppKit (`NSStatusItem`) | SwiftUI for menu content; `NSStatusItem` is the only API for menu bar items |
| App lifecycle | SwiftUI `App` with `MenuBarExtra` | Available since macOS 13; eliminates boilerplate `NSApplicationDelegate` setup |
| Process management | Foundation `Process` | Standard API for spawning and managing child processes |
| Minimum deployment target | macOS 14 (Sonoma) | `MenuBarExtra` matured in macOS 14 with reliable styling; Sonoma+ covers the vast majority of active Macs |
| Build system | Xcode project (`.xcodeproj`) | Standard for macOS apps; required for signing, notarization, and App Store distribution |

---

## Phase 1 — Project scaffolding

**Goal:** A macOS app that launches, shows nothing in the Dock, and places an icon in the menu bar.

### Tasks

1. **Create Xcode project structure.**
   - SwiftUI App lifecycle, macOS target, deployment target macOS 14.
   - Bundle identifier: `com.matootie.macchiato`.
   - Product name: `Macchiato`.

2. **Configure as menu-bar-only app.**
   - Set `LSUIElement = YES` in `Info.plist` (hides Dock icon and app menu).

3. **Add the app entry point.**
   - `MacchiatoApp.swift` using the SwiftUI `App` protocol.
   - Use `MenuBarExtra` scene as the sole scene — no `WindowGroup`.
   - Placeholder menu content (e.g., a "Quit" button) to verify the status item appears.

4. **Add an app icon asset.**
   - Placeholder `AppIcon` in the asset catalog (can be refined later).

### Deliverables

- App builds, launches, shows a menu bar icon, and has no Dock presence.
- Tapping the icon reveals a dropdown with a "Quit" option that terminates the app.

### Verification

- Build and run in Xcode. Confirm: no Dock icon, menu bar icon visible, "Quit" works.

---

## Phase 2 — Caffeinate process management

**Goal:** A service that can start and stop `caffeinate -ds` as a child process, with clean lifecycle handling.

### Tasks

1. **Create `CaffeinateService`.**
   - An `@Observable` class (or `ObservableObject` if needed for compatibility).
   - Published property: `isActive: Bool` — reflects whether caffeinate is currently running.
   - Method: `start()` — spawns `caffeinate -ds` via `Process`. No-op if already running.
   - Method: `stop()` — sends `SIGTERM` to the running process, then waits for termination. No-op if not running.
   - Method: `toggle()` — calls `start()` or `stop()` based on current state.

2. **Handle process termination.**
   - Use `Process.terminationHandler` to detect unexpected exits (e.g., if the user kills caffeinate externally) and update `isActive` accordingly.
   - Ensure the handler dispatches state updates to the main thread.

3. **Handle app termination.**
   - When the app quits, stop the caffeinate process. Register cleanup in `applicationWillTerminate` or use SwiftUI's `onDisappear` / `NSApplication` termination notification.

4. **Resolve the executable path.**
   - Use `/usr/bin/caffeinate` directly — it's a stable system binary.

### Deliverables

- `CaffeinateService` with `start()`, `stop()`, `toggle()`, and observable `isActive` state.
- Caffeinate process is always cleaned up on app quit.
- External process termination is detected and state is updated.

### Verification

- Unit tests for `CaffeinateService`: start sets `isActive` true, stop sets it false, double-start is a no-op, double-stop is a no-op.
- Manual: run the app, start caffeinate, verify with `pgrep caffeinate`, stop it, verify with `pgrep` again. Quit the app while caffeinate is running — confirm the process is gone.

---

## Phase 3 — Menu bar UI

**Goal:** A polished menu bar interface that shows caffeinate status and lets the user toggle it.

### Tasks

1. **Design the menu bar icon.**
   - Use an SF Symbol for the status item image. Candidates: `cup.and.saucer.fill` (active) / `cup.and.saucer` (inactive), or `bolt.fill` / `bolt` to convey "awake" state.
   - The icon should be visually distinct between active and inactive states so the user can tell at a glance.

2. **Build the menu content.**
   - Display current status: a label like "Caffeinate is **on**" / "Caffeinate is **off**".
   - A toggle button: "Turn On" / "Turn Off" (label reflects the action, not the state).
   - A divider.
   - "Quit Macchiato" button.

3. **Wire the UI to `CaffeinateService`.**
   - Inject `CaffeinateService` as environment or state into the menu view.
   - Toggle button calls `service.toggle()`.
   - Icon and labels react to `service.isActive`.

### Deliverables

- Menu bar icon changes appearance based on caffeinate state.
- Dropdown menu shows status, toggle action, and quit.
- All UI state is driven by `CaffeinateService.isActive`.

### Verification

- Build and run. Toggle caffeinate on/off from the menu. Confirm icon changes, label updates, and `pgrep caffeinate` matches the displayed state.

---

## Phase 4 — Launch at Login

**Goal:** Allow the user to opt in to launching Macchiato automatically at login.

### Tasks

1. **Add a `LaunchAtLogin` toggle.**
   - Use `SMAppService.mainApp` (ServiceManagement framework, macOS 13+) to register/unregister the app as a login item.
   - Add a "Launch at Login" toggle (checkmark menu item) to the dropdown menu.
   - Persist the user's preference — `SMAppService` handles this implicitly; the toggle reflects `SMAppService.mainApp.status`.

2. **Handle registration errors.**
   - If registration fails (e.g., user denied in System Settings), show the toggle as unchecked. No error dialogs — keep it silent and non-intrusive.

### Deliverables

- "Launch at Login" menu item that toggles login-item registration.
- State persists across app restarts.

### Verification

- Toggle "Launch at Login" on, quit the app, log out and back in — confirm Macchiato launches.
- Toggle it off, repeat — confirm it does not launch.

---

## Phase 5 — Polish and distribution

**Goal:** Final polish, proper metadata, and a distributable build.

### Tasks

1. **App icon.**
   - Design or source a proper app icon (coffee cup theme). Add to the asset catalog at all required sizes.

2. **About information.**
   - Add an "About Macchiato" menu item that shows a small panel with app name, version (from bundle), and a brief description.

3. **Keyboard shortcut (optional).**
   - Consider a global keyboard shortcut to toggle caffeinate without opening the menu. Use `NSEvent.addGlobalMonitorForEvents` or the newer `KeyboardShortcuts` approach. This is stretch — only if it adds clear value.

4. **Signing and notarization.**
   - Configure code signing with a Developer ID certificate.
   - Set up notarization so the app can be distributed outside the App Store without Gatekeeper warnings.

5. **Build a release archive.**
   - Archive the app in Xcode, export a notarized `.dmg` or `.zip` for distribution.

6. **Update README.**
   - Installation instructions, screenshot of the menu bar UI, and usage description.

### Deliverables

- Polished app icon.
- "About" panel.
- Signed and notarized distributable binary.
- Updated README with screenshot and instructions.

### Verification

- Download the distributable on a clean Mac (or a different user account). Open it — no Gatekeeper warning. Verify all functionality works: toggle, icon state, launch at login, about panel, quit.

---

## Phase summary

| Phase | Scope | Key outcome |
|---|---|---|
| 1 | Scaffolding | App launches in menu bar, no Dock icon |
| 2 | Process management | `CaffeinateService` starts/stops `caffeinate -ds` |
| 3 | Menu bar UI | Toggle, status display, icon state |
| 4 | Launch at Login | `SMAppService` login item registration |
| 5 | Polish & distribution | Icon, about panel, signing, README |

Each phase builds on the previous one and produces a working (if incomplete) app. Phases 1–3 constitute the MVP.
