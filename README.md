# Macchiato

Macchiato is a lightweight macOS menu bar app that toggles `caffeinate -ds` with a single click. No terminal window required.

## Features

- **One-click sleep prevention** - click the menu bar icon to toggle `caffeinate -ds` on or off.
- **Visual status** - the menu bar icon fills in when caffeinate is active, so you can tell at a glance.
- **Launch at Login** - optionally start Macchiato when you log in.
- **Zero footprint** - no Dock icon, no windows, just a menu bar item.

## Requirements

- macOS 14 (Sonoma) or later

## Installation

Download the latest `.dmg` from Releases, open it, and drag Macchiato to your Applications folder.

## Building from source

Open `Macchiato.xcodeproj` in Xcode 15+ and run the Macchiato scheme.

To run tests:

```
xcodebuild test -project Macchiato.xcodeproj -scheme Macchiato -destination 'platform=macOS'
```

## Usage

1. Launch Macchiato. A coffee cup icon appears in the menu bar.
2. Click the icon to open the menu.
3. Click **Turn On** to start `caffeinate -ds` (prevents display and system sleep).
4. The icon fills in to indicate caffeinate is active.
5. Click **Turn Off** to stop it.

Caffeinate is automatically stopped when you quit Macchiato.

