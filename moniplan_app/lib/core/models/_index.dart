// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

export 'currency_data/_index.dart';
export 'datetime/date_time_repeat.dart';
export 'payment/_index.dart';
export 'planner/_index.dart';

abstract class IMapper<Domain, Dto> {
  Dto toDto(Domain data);
  Domain toDomain(Dto data);
}
