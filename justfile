#!/usr/bin/env just --justfile
call_recipe := just_executable() + " --justfile=" + justfile()
ver dir='.':
    cd {{dir}} && echo $(if command -v yq >/dev/null; then yq -r '.version' {{dir}}/pubspec.yaml; else grep -E '^\s*version:' pubspec.yaml | head -n1 | sed -E 's/^\s*version:\s*"?([^"#]+)"?\s*(#.*)?$/\1/'; fi)
pg dir: # Pubget
    cd {{dir}} && fvm dart pub get
br dir: # Build runner
    cd {{dir}} && fvm dart pub get
    cd {{dir}} && fvm dart run build_runner build --delete-conflicting-outputs
cl_br dir: # Clean build runner
    cd {{dir}} && fvm dart run build_runner clean
cl dir: # Flutter clean
    cd {{dir}} && fvm flutter clean

pubget:
    {{call_recipe}} pg monishare
    {{call_recipe}} pg moniplan_uikit
    {{call_recipe}} pg moniplan_app

runner:
    {{call_recipe}} pg moniplan_uikit
    {{call_recipe}} br moniplan_app

clean:
    {{call_recipe}} cl moniplan_app
    {{call_recipe}} cl_br moniplan_app
    {{call_recipe}} cl moniplan_uikit

license:
    reuse annotate -c "Karim \"nogipx\" Mamatkazin <nogipx@gmail.com>" -l "GPL-3.0-or-later" --skip-unrecognised -r moniplan_app/lib
    reuse annotate -c "Karim \"nogipx\" Mamatkazin <nogipx@gmail.com>" -l "GPL-3.0-or-later" --skip-unrecognised -r moniplan_core/lib
    reuse annotate -c "Karim \"nogipx\" Mamatkazin <nogipx@gmail.com>" -l "GPL-3.0-or-later" --skip-unrecognised -r moniplan_domain/lib
    reuse annotate -c "Karim \"nogipx\" Mamatkazin <nogipx@gmail.com>" -l "GPL-3.0-or-later" --skip-unrecognised -r moniplan_uikit/lib

release_dmg:
    cd moniplan_app/macos && pod install --repo-update 
    cd moniplan_app && fvm flutter build macos --release --obfuscate --split-debug-info=../.artifacts/dmg-debug-info
    mkdir -p .artifacts
    rm -f .artifacts/moniplan.dmg || true
    # Создание DMG без внешнего create-dmg: используем hdiutil (логика из create_dmg.sh)
    cd moniplan_app && \
      APP_NAME="moniplan" && \
      DMG_NAME="${APP_NAME}.dmg" && \
      APP_PATH="build/macos/Build/Products/Release/${APP_NAME}.app" && \
      DMG_PATH="../.artifacts/${DMG_NAME}" && \
      rm -f "${DMG_PATH}" && \
      mkdir -p dist/tmp && \
      cp -R "${APP_PATH}" dist/tmp/ && \
      hdiutil create -volname "${APP_NAME}" -srcfolder "dist/tmp" -ov -format UDZO "${DMG_PATH}" && \
      rm -rf dist

release_apk:
    cd moniplan_app && fvm flutter build apk --release --obfuscate --split-debug-info=../.artifacts/apk-debug-info
    mkdir -p ../.artifacts
    rm -f ../.artifacts/moniplan.apk || true
    cd moniplan_app && cp build/app/outputs/flutter-apk/app-release.apk ../.artifacts/moniplan_$(just ver moniplan_app).apk

update_env:
    if [ -f moniplan_app/lib/core/config/env.g.dart ]; then rm moniplan_app/lib/core/config/env.g.dart; fi
    cd moniplan_app && fvm dart run build_runner clean
    cd moniplan_app && fvm dart run build_runner build --delete-conflicting-outputs