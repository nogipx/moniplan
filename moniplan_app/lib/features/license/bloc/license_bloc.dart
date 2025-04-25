// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:moniplan_app/features/license/bloc/license_event.dart';
import 'package:moniplan_app/features/license/bloc/license_state.dart';
import 'package:moniplan_domain/moniplan_domain.dart';

class LicenseBloc extends Bloc<LicenseEvent, LicenseState> {
  final IMoniplanLicenseRepo _repository;
  final LicenseFeaturesService _licenseFeaturesService;
  final IFeaturesManager _featuresManager;
  LicenseBloc({
    required IMoniplanLicenseRepo repository,
    required LicenseFeaturesService licenseFeaturesService,
    required IFeaturesManager featuresManager,
  }) : _repository = repository,
       _licenseFeaturesService = licenseFeaturesService,
       _featuresManager = featuresManager,
       super(const LicenseInitialState()) {
    on<LicenseAddedEvent>(_onLicenseAdded);
    on<LicenseLoadedEvent>(_onLicenseLoaded);
    on<LicenseUpdatedEvent>(_onLicenseUpdated);
    on<LicenseDeletedEvent>(_onLicenseDeleted);
    on<LicenseStatusCheckedEvent>(_onLicenseStatusChecked);
  }

  /// Обновляет сервис лицензионных возможностей
  Future<void> _refreshLicenseFeatures() async {
    try {
      // Обновляем лицензию в сервисе функций
      await _licenseFeaturesService.refreshLicense();

      // Если AppFeaturesManager инициализирован, обновляем фичефлаги
      try {
        _featuresManager.forceReloadFeatures();
      } catch (e) {
        // AppFeaturesManager может быть не инициализирован
      }
    } catch (e) {
      // Игнорируем ошибки
    }
  }

  Future<void> _onLicenseAdded(LicenseAddedEvent event, Emitter<LicenseState> emit) async {
    emit(const LicenseLoadingState());

    try {
      // Проверяем валидность лицензии перед сохранением
      final licenseBytes = Uint8List.fromList(event.licenseBytes);
      final license = await _repository.decodeLicense(licenseBytes: licenseBytes);

      if (license == null) {
        emit(const LicenseErrorState(message: 'Не удалось декодировать лицензию'));
        return;
      }

      // Сохраняем лицензию в любом случае
      await _repository.saveLicense(license);

      // Обновляем сервис лицензионных функций
      await _refreshLicenseFeatures();

      // Получаем статус через сервис лицензионных функций
      final licenseStatusType = await _licenseFeaturesService.getLicenseStatusType();

      switch (licenseStatusType) {
        case LicenseStatusType.valid:
          emit(LicenseValidState(license: license));
          break;
        case LicenseStatusType.expired:
          emit(LicenseExpiredState(license: license));
          break;
        case LicenseStatusType.wrongDevice:
          emit(LicenseWrongDeviceState(license: license));
          break;
        case LicenseStatusType.invalid:
          emit(LicenseInvalidState(message: 'Недействительная лицензия', license: license));
          break;
        default:
          // Этот случай не должен наступить, т.к. лицензия существует
          emit(LicenseInvalidState(message: 'Неизвестный статус лицензии', license: license));
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
        // Обновляем сервис лицензионных функций
        await _refreshLicenseFeatures();

        // Получаем статус через сервис лицензионных функций
        final licenseStatusType = await _licenseFeaturesService.getLicenseStatusType();

        switch (licenseStatusType) {
          case LicenseStatusType.valid:
            emit(LicenseValidState(license: license));
            break;
          case LicenseStatusType.expired:
            emit(LicenseExpiredState(license: license));
            break;
          case LicenseStatusType.wrongDevice:
            emit(LicenseWrongDeviceState(license: license));
            break;
          case LicenseStatusType.invalid:
            emit(LicenseInvalidState(message: 'Недействительная лицензия', license: license));
            break;
          default:
            // Этот случай не должен наступить, т.к. лицензия существует
            emit(LicenseInvalidState(message: 'Неизвестный статус лицензии', license: license));
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

      if (license == null) {
        emit(const LicenseErrorState(message: 'Не удалось декодировать лицензию'));
        return;
      }

      // Удаляем старую лицензию
      await _repository.removeLicense();

      // Сохраняем новую лицензию независимо от её статуса
      await _repository.saveLicense(license);

      // Обновляем сервис лицензионных функций
      await _refreshLicenseFeatures();

      // Получаем статус через сервис лицензионных функций
      final licenseStatusType = await _licenseFeaturesService.getLicenseStatusType();

      switch (licenseStatusType) {
        case LicenseStatusType.valid:
          emit(LicenseValidState(license: license));
          break;
        case LicenseStatusType.expired:
          emit(LicenseExpiredState(license: license));
          break;
        case LicenseStatusType.wrongDevice:
          emit(LicenseWrongDeviceState(license: license));
          break;
        case LicenseStatusType.invalid:
          emit(LicenseInvalidState(message: 'Недействительная лицензия', license: license));
          break;
        default:
          // Этот случай не должен наступить, т.к. лицензия существует
          emit(LicenseInvalidState(message: 'Неизвестный статус лицензии', license: license));
      }
    } catch (e) {
      emit(LicenseErrorState(message: 'Не удалось обновить лицензию: ${e.toString()}', error: e));
    }
  }

  Future<void> _onLicenseDeleted(LicenseDeletedEvent event, Emitter<LicenseState> emit) async {
    emit(const LicenseLoadingState());

    try {
      await _repository.removeLicense();

      // Обновляем сервис лицензионных функций
      await _refreshLicenseFeatures();

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
        // Обновляем сервис лицензионных функций
        await _refreshLicenseFeatures();

        // Получаем статус через сервис лицензионных функций
        final licenseStatusType = await _licenseFeaturesService.getLicenseStatusType();

        switch (licenseStatusType) {
          case LicenseStatusType.valid:
            emit(LicenseValidState(license: license));
            break;
          case LicenseStatusType.expired:
            emit(LicenseExpiredState(license: license));
            break;
          case LicenseStatusType.wrongDevice:
            emit(LicenseWrongDeviceState(license: license));
            break;
          case LicenseStatusType.invalid:
            emit(LicenseInvalidState(message: 'Недействительная лицензия', license: license));
            break;
          default:
            // Этот случай не должен наступить, т.к. лицензия существует
            emit(LicenseInvalidState(message: 'Неизвестный статус лицензии', license: license));
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
