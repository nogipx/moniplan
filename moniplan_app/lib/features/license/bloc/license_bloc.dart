// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moniplan_app/features/license/bloc/license_event.dart';
import 'package:moniplan_app/features/license/bloc/license_state.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

class LicenseBloc extends Bloc<LicenseEvent, LicenseState> {
  final IMoniplanLicenseRepo _repository;

  LicenseBloc({required IMoniplanLicenseRepo repository})
    : _repository = repository,
      super(const LicenseInitialState()) {
    on<LicenseAddedEvent>(_onLicenseAdded);
    on<LicenseLoadedEvent>(_onLicenseLoaded);
    on<LicenseUpdatedEvent>(_onLicenseUpdated);
    on<LicenseDeletedEvent>(_onLicenseDeleted);
    on<LicenseStatusCheckedEvent>(_onLicenseStatusChecked);
  }

  Future<void> _onLicenseAdded(LicenseAddedEvent event, Emitter<LicenseState> emit) async {
    emit(const LicenseLoadingState());

    try {
      // Проверяем валидность лицензии перед сохранением
      final licenseBytes = Uint8List.fromList(event.licenseBytes);
      final license = await _repository.decodeLicense(licenseBytes: licenseBytes);
      final checkLicenseResult = await _repository.getLicenseStatus(license: license);

      if (license != null && checkLicenseResult.isActive) {
        // Сохраняем лицензию
        await _repository.saveLicense(license);
        emit(LicenseValidState(license: license));
      } else {
        // Ошибка валидации
        emit(LicenseErrorState(message: 'Ошибка валидации лицензии', error: checkLicenseResult));
      }
    } catch (e) {
      emit(LicenseErrorState(message: 'Не удалось добавить лицензию: ${e.toString()}', error: e));
    }
  }

  Future<void> _onLicenseLoaded(LicenseLoadedEvent event, Emitter<LicenseState> emit) async {
    emit(const LicenseLoadingState());

    try {
      final license = await _repository.getCurrentLicense();

      if (license != null) {
        // Проверяем статус лицензии
        final checkLicenseResult = await _repository.getLicenseStatus(license: license);

        if (checkLicenseResult.isActive) {
          // Проверяем срок действия
          if (license.isExpired) {
            emit(LicenseExpiredState(license: license));
          } else {
            emit(LicenseValidState(license: license));
          }
        } else {
          emit(LicenseInvalidState(message: 'Недействительная лицензия', license: license));
        }
      } else {
        emit(const LicenseNotFoundState());
      }
    } catch (e) {
      emit(LicenseErrorState(message: 'Не удалось загрузить лицензию: ${e.toString()}', error: e));
    }
  }

  Future<void> _onLicenseUpdated(LicenseUpdatedEvent event, Emitter<LicenseState> emit) async {
    emit(const LicenseLoadingState());

    try {
      // Проверяем валидность новой лицензии перед обновлением
      final licenseBytes = Uint8List.fromList(event.licenseBytes);
      final license = await _repository.decodeLicense(licenseBytes: licenseBytes);
      final checkLicenseResult = await _repository.getLicenseStatus(license: license);
      if (license != null && checkLicenseResult.isActive) {
        // Удаляем старую лицензию и сохраняем новую
        await _repository.removeLicense();
        await _repository.saveLicense(license);

        emit(LicenseValidState(license: license));
      } else {
        emit(LicenseErrorState(message: 'Ошибка валидации лицензии', error: checkLicenseResult));
      }
    } catch (e) {
      emit(LicenseErrorState(message: 'Не удалось обновить лицензию: ${e.toString()}', error: e));
    }
  }

  Future<void> _onLicenseDeleted(LicenseDeletedEvent event, Emitter<LicenseState> emit) async {
    emit(const LicenseLoadingState());

    try {
      await _repository.removeLicense();
      emit(const LicenseNotFoundState());
    } catch (e) {
      emit(LicenseErrorState(message: 'Не удалось удалить лицензию: ${e.toString()}', error: e));
    }
  }

  Future<void> _onLicenseStatusChecked(
    LicenseStatusCheckedEvent event,
    Emitter<LicenseState> emit,
  ) async {
    emit(const LicenseLoadingState());

    try {
      final license = await _repository.getCurrentLicense();

      if (license != null) {
        // Проверяем статус лицензии
        final result = await _repository.getLicenseStatus();

        if (result.isActive) {
          // Проверяем срок действия
          if (license.isExpired) {
            emit(LicenseExpiredState(license: license));
          } else {
            emit(LicenseValidState(license: license));
          }
        } else {
          emit(LicenseInvalidState(message: 'Недействительная лицензия', license: license));
        }
      } else {
        emit(const LicenseNotFoundState());
      }
    } catch (e) {
      emit(
        LicenseErrorState(
          message: 'Не удалось проверить статус лицензии: ${e.toString()}',
          error: e,
        ),
      );
    }
  }
}
