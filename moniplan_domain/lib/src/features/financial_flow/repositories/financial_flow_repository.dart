// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import '../models/financial_flow_profile.dart';
import '../models/financial_flow_calculation.dart';
import '../models/financial_instrument.dart';

/// Репозиторий для работы с профилями финансового потока
abstract class FinancialFlowRepository {
  /// Получает все профили пользователя
  Future<List<FinancialFlowProfile>> getAllProfiles();
  
  /// Получает профиль по идентификатору
  Future<FinancialFlowProfile?> getProfileById(String id);
  
  /// Создает новый профиль
  Future<FinancialFlowProfile> createProfile(FinancialFlowProfile profile);
  
  /// Обновляет существующий профиль
  Future<FinancialFlowProfile> updateProfile(FinancialFlowProfile profile);
  
  /// Удаляет профиль
  Future<void> deleteProfile(String id);
  
  /// Получает профили по тегам
  Future<List<FinancialFlowProfile>> getProfilesByTags(Set<String> tags);
  
  /// Получает активные профили
  Future<List<FinancialFlowProfile>> getActiveProfiles();
  
  // Работа с инструментами
  
  /// Добавляет инструмент в профиль
  Future<FinancialFlowProfile> addInstrumentToProfile(
    String profileId, 
    FinancialInstrument instrument,
  );
  
  /// Обновляет инструмент в профиле
  Future<FinancialFlowProfile> updateInstrumentInProfile(
    String profileId, 
    FinancialInstrument instrument,
  );
  
  /// Удаляет инструмент из профиля
  Future<FinancialFlowProfile> removeInstrumentFromProfile(
    String profileId, 
    String instrumentId,
  );
  
  /// Получает все инструменты пользователя (из всех профилей)
  Future<List<FinancialInstrument>> getAllInstruments();
  
  /// Получает инструменты по типу
  Future<List<FinancialInstrument>> getInstrumentsByType(FinancialInstrumentType type);
  
  // Работа с расчетами
  
  /// Сохраняет результат расчета
  Future<FinancialFlowCalculation> saveCalculation(FinancialFlowCalculation calculation);
  
  /// Получает расчеты для профиля
  Future<List<FinancialFlowCalculation>> getCalculationsForProfile(String profileId);
  
  /// Получает последний расчет для профиля
  Future<FinancialFlowCalculation?> getLatestCalculationForProfile(String profileId);
  
  /// Удаляет старые расчеты (старше указанного количества дней)
  Future<void> cleanupOldCalculations(int olderThanDays);
}

/// Реализация репозитория в памяти (для тестирования и прототипирования)
class InMemoryFinancialFlowRepository implements FinancialFlowRepository {
  final Map<String, FinancialFlowProfile> _profiles = {};
  final Map<String, FinancialFlowCalculation> _calculations = {};

  @override
  Future<List<FinancialFlowProfile>> getAllProfiles() async {
    return _profiles.values.toList();
  }

  @override
  Future<FinancialFlowProfile?> getProfileById(String id) async {
    return _profiles[id];
  }

  @override
  Future<FinancialFlowProfile> createProfile(FinancialFlowProfile profile) async {
    final updatedProfile = profile.copyWith(
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _profiles[profile.id] = updatedProfile;
    return updatedProfile;
  }

  @override
  Future<FinancialFlowProfile> updateProfile(FinancialFlowProfile profile) async {
    final updatedProfile = profile.copyWith(
      updatedAt: DateTime.now(),
    );
    _profiles[profile.id] = updatedProfile;
    return updatedProfile;
  }

  @override
  Future<void> deleteProfile(String id) async {
    _profiles.remove(id);
    
    // Удаляем связанные расчеты
    final calculationsToRemove = _calculations.entries
        .where((entry) => entry.value.profile.id == id)
        .map((entry) => entry.key)
        .toList();
    
    for (final calcId in calculationsToRemove) {
      _calculations.remove(calcId);
    }
  }

  @override
  Future<List<FinancialFlowProfile>> getProfilesByTags(Set<String> tags) async {
    return _profiles.values
        .where((profile) => profile.tags.any((tag) => tags.contains(tag)))
        .toList();
  }

  @override
  Future<List<FinancialFlowProfile>> getActiveProfiles() async {
    return _profiles.values
        .where((profile) => profile.isActive)
        .toList();
  }

  @override
  Future<FinancialFlowProfile> addInstrumentToProfile(
    String profileId, 
    FinancialInstrument instrument,
  ) async {
    final profile = _profiles[profileId];
    if (profile == null) {
      throw Exception('Profile not found: $profileId');
    }

    final updatedInstruments = [...profile.instruments, instrument];
    final updatedProfile = profile.copyWith(
      instruments: updatedInstruments,
      updatedAt: DateTime.now(),
    );
    
    _profiles[profileId] = updatedProfile;
    return updatedProfile;
  }

  @override
  Future<FinancialFlowProfile> updateInstrumentInProfile(
    String profileId, 
    FinancialInstrument instrument,
  ) async {
    final profile = _profiles[profileId];
    if (profile == null) {
      throw Exception('Profile not found: $profileId');
    }

    final updatedInstruments = profile.instruments
        .map((existing) => existing.id == instrument.id ? instrument : existing)
        .toList();
    
    final updatedProfile = profile.copyWith(
      instruments: updatedInstruments,
      updatedAt: DateTime.now(),
    );
    
    _profiles[profileId] = updatedProfile;
    return updatedProfile;
  }

  @override
  Future<FinancialFlowProfile> removeInstrumentFromProfile(
    String profileId, 
    String instrumentId,
  ) async {
    final profile = _profiles[profileId];
    if (profile == null) {
      throw Exception('Profile not found: $profileId');
    }

    final updatedInstruments = profile.instruments
        .where((instrument) => instrument.id != instrumentId)
        .toList();
    
    final updatedProfile = profile.copyWith(
      instruments: updatedInstruments,
      updatedAt: DateTime.now(),
    );
    
    _profiles[profileId] = updatedProfile;
    return updatedProfile;
  }

  @override
  Future<List<FinancialInstrument>> getAllInstruments() async {
    return _profiles.values
        .expand((profile) => profile.instruments)
        .toList();
  }

  @override
  Future<List<FinancialInstrument>> getInstrumentsByType(FinancialInstrumentType type) async {
    return _profiles.values
        .expand((profile) => profile.instruments)
        .where((instrument) => instrument.type == type)
        .toList();
  }

  @override
  Future<FinancialFlowCalculation> saveCalculation(FinancialFlowCalculation calculation) async {
    _calculations[calculation.id] = calculation;
    return calculation;
  }

  @override
  Future<List<FinancialFlowCalculation>> getCalculationsForProfile(String profileId) async {
    return _calculations.values
        .where((calculation) => calculation.profile.id == profileId)
        .toList()
      ..sort((a, b) => b.calculatedAt.compareTo(a.calculatedAt));
  }

  @override
  Future<FinancialFlowCalculation?> getLatestCalculationForProfile(String profileId) async {
    final calculations = await getCalculationsForProfile(profileId);
    return calculations.isNotEmpty ? calculations.first : null;
  }

  @override
  Future<void> cleanupOldCalculations(int olderThanDays) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: olderThanDays));
    
    final calculationsToRemove = _calculations.entries
        .where((entry) => entry.value.calculatedAt.isBefore(cutoffDate))
        .map((entry) => entry.key)
        .toList();
    
    for (final calcId in calculationsToRemove) {
      _calculations.remove(calcId);
    }
  }
}
