#!/usr/bin/env just --justfile

pubget_all:
    fvm dart run packo pubget -r

runner_all:
    fvm dart run packo runner -r

runner_core:
    fvm dart run packo runner -b moniplan_core

runner_domain:
    fvm dart run packo runner -b moniplan_domain

generate_arb:
    fvm dart run packo runner -b moniplan_domain

    cd moniplan_domain && fvm dart run keys_generator:to_arb \
      -f lib/keys/moniplan.keys.yml \
      -o ../lib/i18n/arb/intl_ru.arb

    cd moniplan_domain && fvm dart run keys_generator:to_arb \
      -f lib/keys/moniplan.keys.yml \
      -o ../lib/i18n/arb/intl_en.arb
