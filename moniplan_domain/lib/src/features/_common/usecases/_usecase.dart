// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

abstract interface class IUseCase<T> {
  const IUseCase();
  T run();
}

abstract interface class IUseCaseAsync<T> extends IUseCase<FutureOr<T>> {}
