#!/usr/bin/env just --justfile

pubget_all:
    fvm dart run packo pubget -g moniplan

runner_all:
    fvm dart run packo runner -r

runner_app:
    fvm dart run packo runner -b moniplan_app

runner_core:
    fvm dart run packo runner -b moniplan_core

runner_domain:
    fvm dart run packo runner -b moniplan_domain

runner_clean:
    cd moniplan_app && fvm dart run build_runner clean

generate_arb:
    fvm dart run packo runner -b moniplan_domain

    cd moniplan_domain && fvm dart run keys_generator:to_arb \
      -f lib/keys/moniplan.keys.yml \
      -o ../moniplan_app/lib/i18n/arb/intl_ru.arb

    cd moniplan_domain && fvm dart run keys_generator:to_arb \
      -f lib/keys/moniplan.keys.yml \
      -o ../moniplan_app/lib/i18n/arb/intl_en.arb

license:
    reuse annotate -c "Karim \"nogipx\" Mamatkazin <nogipx@gmail.com>" -l "GPL-3.0-or-later" --skip-unrecognised -r moniplan_app/lib
    reuse annotate -c "Karim \"nogipx\" Mamatkazin <nogipx@gmail.com>" -l "GPL-3.0-or-later" --skip-unrecognised -r moniplan_core/lib
    reuse annotate -c "Karim \"nogipx\" Mamatkazin <nogipx@gmail.com>" -l "GPL-3.0-or-later" --skip-unrecognised -r moniplan_domain/lib
    reuse annotate -c "Karim \"nogipx\" Mamatkazin <nogipx@gmail.com>" -l "GPL-3.0-or-later" --skip-unrecognised -r moniplan_uikit/lib

release_dmg:
    cd moniplan_app/macos && pod install --repo-update 
    cd moniplan_app && fvm flutter build macos --release --obfuscate --split-debug-info=./.debug-info
    mkdir -p ../.artifacts
    rm -f ../.artifacts/moniplan.dmg || true
    cd moniplan_app && /opt/homebrew/bin/create-dmg \
      "../.artifacts/moniplan.dmg" \
      "build/macos/Build/Products/Release/moniplan.app"
      
release_apk:
    cd moniplan_app && fvm flutter build apk --release --obfuscate --split-debug-info=./.debug-info
    mkdir -p ../.artifacts
    rm -f ../.artifacts/moniplan.apk || true
    cd moniplan_app && cp build/app/outputs/flutter-apk/app-release.apk ../.artifacts/moniplan_$(fvm dart run packo helpers --current-version).apk

update_env:
    if [ -f moniplan_app/lib/core/config/env.g.dart ]; then rm moniplan_app/lib/core/config/env.g.dart; fi
    cd moniplan_app && fvm dart run build_runner clean
    cd moniplan_app && fvm dart run build_runner build --delete-conflicting-outputs