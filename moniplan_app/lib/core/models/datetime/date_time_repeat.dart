// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:moniplan_app/utils/_index.dart';

/// Конвертер для сериализации/десериализации DateTimeRepeat
class DateTimeRepeatConverter implements JsonConverter<DateTimeRepeat, int> {
  const DateTimeRepeatConverter();

  @override
  DateTimeRepeat fromJson(int json) => DateTimeRepeat.from(json);

  @override
  int toJson(DateTimeRepeat object) => object.id;
}

enum DateTimeRepeatType { none, day, week, month, year }

class DateTimeRepeat {
  final DateTimeRepeatType type;
  final int value;
  final int id;
  final String shortName;

  const DateTimeRepeat._({
    required this.type,
    required this.value,
    required this.id,
    required this.shortName,
  });

  // Предопределенные периоды повторения
  static const noRepeat = DateTimeRepeat._(
    type: DateTimeRepeatType.none,
    value: 0,
    id: 0,
    shortName: '',
  );

  // Дни
  static const day = DateTimeRepeat._(
    type: DateTimeRepeatType.day,
    value: 1,
    id: 1,
    shortName: '1d',
  );

  // Недели
  static const week = DateTimeRepeat._(
    type: DateTimeRepeatType.week,
    value: 1,
    id: 7,
    shortName: '1w',
  );

  // Месяцы
  static const month = DateTimeRepeat._(
    type: DateTimeRepeatType.month,
    value: 1,
    id: 11,
    shortName: '1m',
  );

  // Годы
  static const year = DateTimeRepeat._(
    type: DateTimeRepeatType.year,
    value: 1,
    id: 22,
    shortName: '1y',
  );

  // Список всех предопределенных периодов
  static const List<DateTimeRepeat> values = [noRepeat, day, week, month, year];

  // Создание пользовательского периода повторения
  static DateTimeRepeat custom({required DateTimeRepeatType type, required int value}) {
    if (type == DateTimeRepeatType.none || value <= 0) {
      return noRepeat;
    }

    // Проверяем, есть ли предопределенный период с такими параметрами
    for (final preset in values) {
      if (preset.type == type && preset.value == value) {
        return preset;
      }
    }

    // Генерируем уникальный ID для пользовательского периода
    // Базовый ID для каждого типа + значение
    int id;
    String shortName;

    switch (type) {
      case DateTimeRepeatType.day:
        id = 100 + value;
        shortName = '${value}d';
      case DateTimeRepeatType.week:
        id = 200 + value;
        shortName = '${value}w';
      case DateTimeRepeatType.month:
        id = 300 + value;
        shortName = '${value}m';
      case DateTimeRepeatType.year:
        id = 400 + value;
        shortName = '${value}y';
      case DateTimeRepeatType.none:
        return noRepeat;
    }

    return DateTimeRepeat._(type: type, value: value, id: id, shortName: shortName);
  }

  DateTime previous(DateTime base) {
    if (type == DateTimeRepeatType.none) {
      return base;
    }

    switch (type) {
      case DateTimeRepeatType.day:
        return base.subtractTime(day: value);
      case DateTimeRepeatType.week:
        return base.subtractTime(day: value * 7);
      case DateTimeRepeatType.month:
        return base.subtractTime(month: value);
      case DateTimeRepeatType.year:
        return base.subtractTime(year: value);
      case DateTimeRepeatType.none:
        return base;
    }
  }

  DateTime next(DateTime base) {
    if (type == DateTimeRepeatType.none) {
      return base;
    }

    switch (type) {
      case DateTimeRepeatType.day:
        return base.addTime(day: value);
      case DateTimeRepeatType.week:
        return base.addTime(day: value * 7);
      case DateTimeRepeatType.month:
        return base.addTime(month: value);
      case DateTimeRepeatType.year:
        return base.addTime(year: value);
      case DateTimeRepeatType.none:
        return base;
    }
  }

  // Получение периода по ID
  static DateTimeRepeat from(int? id) {
    if (id == null) return noRepeat;

    // Проверяем предопределенные периоды
    for (final preset in values) {
      if (preset.id == id) {
        return preset;
      }
    }

    // Если ID не найден среди предопределенных, пытаемся восстановить пользовательский период
    if (id >= 100 && id < 200) {
      // Дни
      return custom(type: DateTimeRepeatType.day, value: id - 100);
    } else if (id >= 200 && id < 300) {
      // Недели
      return custom(type: DateTimeRepeatType.week, value: id - 200);
    } else if (id >= 300 && id < 400) {
      // Месяцы
      return custom(type: DateTimeRepeatType.month, value: id - 300);
    } else if (id >= 400 && id < 500) {
      // Годы
      return custom(type: DateTimeRepeatType.year, value: id - 400);
    }

    return noRepeat;
  }

  // Получение человекочитаемого названия периода
  String get displayName {
    if (type == DateTimeRepeatType.none) {
      return 'Без повторения';
    }

    switch (type) {
      case DateTimeRepeatType.day:
        if (value == 1) return 'Ежедневно';
        return 'Каждые $value ${_getDaysForm(value)}';
      case DateTimeRepeatType.week:
        if (value == 1) return 'Еженедельно';
        return 'Каждые $value ${_getWeeksForm(value)}';
      case DateTimeRepeatType.month:
        if (value == 1) {
          return 'Ежемесячно';
        } else if (value == 3) {
          return 'Ежеквартально';
        } else if (value == 6) {
          return 'Раз в полгода';
        }
        return 'Каждые $value ${_getMonthsForm(value)}';
      case DateTimeRepeatType.year:
        if (value == 1) return 'Ежегодно';
        return 'Каждые $value ${_getYearsForm(value)}';
      case DateTimeRepeatType.none:
        return 'Без повторения';
    }
  }

  // Вспомогательные методы для склонения слов
  String _getDaysForm(int days) {
    if (days % 10 == 1 && days % 100 != 11) {
      return 'день';
    } else if ([2, 3, 4].contains(days % 10) && ![12, 13, 14].contains(days % 100)) {
      return 'дня';
    } else {
      return 'дней';
    }
  }

  String _getWeeksForm(int weeks) {
    if (weeks % 10 == 1 && weeks % 100 != 11) {
      return 'неделю';
    } else if ([2, 3, 4].contains(weeks % 10) && ![12, 13, 14].contains(weeks % 100)) {
      return 'недели';
    } else {
      return 'недель';
    }
  }

  String _getMonthsForm(int months) {
    if (months % 10 == 1 && months % 100 != 11) {
      return 'месяц';
    } else if ([2, 3, 4].contains(months % 10) && ![12, 13, 14].contains(months % 100)) {
      return 'месяца';
    } else {
      return 'месяцев';
    }
  }

  String _getYearsForm(int years) {
    if (years % 10 == 1 && years % 100 != 11) {
      return 'год';
    } else if ([2, 3, 4].contains(years % 10) && ![12, 13, 14].contains(years % 100)) {
      return 'года';
    } else {
      return 'лет';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateTimeRepeat && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
