#!/usr/bin/env bash
set -euo pipefail

# Macchiato release script
# Builds, signs, packages, and notarizes the app for distribution.
#
# Prerequisites:
#   - A "Developer ID Application" certificate installed in your keychain
#   - An app-specific password stored in the keychain for notarization:
#       xcrun notarytool store-credentials "macchiato-notary" \
#           --apple-id "your@email.com" \
#           --team-id "C4WH2VFRA8" \
#           --password "your-app-specific-password"
#
# Usage:
#   ./scripts/release.sh
#
# The script produces: build/Macchiato-<version>.dmg (signed, notarized, stapled)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build"
APP_NAME="Macchiato"
PROJECT="$PROJECT_DIR/$APP_NAME.xcodeproj"

# Resolve signing identity
IDENTITY=$(security find-identity -v -p codesigning | grep "Developer ID Application" | head -1 | sed 's/.*"\(.*\)".*/\1/' || true)
if [ -z "$IDENTITY" ]; then
    echo "Error: No 'Developer ID Application' certificate found."
    echo "Create one at https://developer.apple.com/account/resources/certificates/add"
    exit 1
fi
echo "Signing with: $IDENTITY"

# Clean and build
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$APP_NAME" \
    -configuration Release \
    -archivePath "$BUILD_DIR/$APP_NAME.xcarchive" \
    CODE_SIGN_IDENTITY="$IDENTITY" \
    DEVELOPMENT_TEAM=C4WH2VFRA8 \
    CODE_SIGN_STYLE=Manual \
    | tail -1

# Export the app from the archive
cat > "$BUILD_DIR/export-options.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>developer-id</string>
    <key>teamID</key>
    <string>C4WH2VFRA8</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>signingCertificate</key>
    <string>Developer ID Application</string>
</dict>
</plist>
PLIST

xcodebuild -exportArchive \
    -archivePath "$BUILD_DIR/$APP_NAME.xcarchive" \
    -exportPath "$BUILD_DIR/export" \
    -exportOptionsPlist "$BUILD_DIR/export-options.plist" \
    | tail -1

APP_PATH="$BUILD_DIR/export/$APP_NAME.app"

# Read version from the built app
VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$APP_PATH/Contents/Info.plist")
DMG_NAME="$APP_NAME-$VERSION.dmg"
DMG_PATH="$BUILD_DIR/$DMG_NAME"

echo "Packaging $APP_NAME $VERSION"

# Create DMG
hdiutil create -volname "$APP_NAME" \
    -srcfolder "$APP_PATH" \
    -ov -format UDZO \
    "$DMG_PATH" \
    > /dev/null

# Notarize
echo "Submitting for notarization..."
xcrun notarytool submit "$DMG_PATH" \
    --keychain-profile "macchiato-notary" \
    --wait

# Staple the notarization ticket
xcrun stapler staple "$DMG_PATH"

echo ""
echo "Done: $DMG_PATH"
