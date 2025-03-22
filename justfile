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
