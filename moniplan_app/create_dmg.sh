# create_dmg.sh
APP_NAME="moniplan"
VERSION=""
DMG_NAME="${APP_NAME}.dmg"
APP_PATH="dist/${APP_NAME}.app"
DMG_PATH="dist/${DMG_NAME}"

# Remove any existing DMG
rm -f "${DMG_PATH}"

# Create a temporary directory
mkdir -p dist/tmp
cp -R "${APP_PATH}" dist/tmp/

# Create the DMG
hdiutil create -volname "${APP_NAME}" -srcfolder "dist/tmp" -ov -format UDZO "${DMG_PATH}"

# Clean up
rm -rf dist/tmp

echo "DMG created at ${DMG_PATH}"