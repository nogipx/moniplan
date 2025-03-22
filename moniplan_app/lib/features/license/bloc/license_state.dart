// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:equatable/equatable.dart';
import 'package:licensify/licensify.dart';

abstract class LicenseState extends Equatable {
  const LicenseState();

  @override
  List<Object?> get props => [];
}

class LicenseInitialState extends LicenseState {
  const LicenseInitialState();
}

class LicenseLoadingState extends LicenseState {
  const LicenseLoadingState();
}

class LicenseLoadedState extends LicenseState {
  final License license;

  const LicenseLoadedState({required this.license});

  @override
  List<Object?> get props => [license];
}

class LicenseNotFoundState extends LicenseState {
  const LicenseNotFoundState();
}

class LicenseErrorState extends LicenseState {
  final String message;
  final Object? error;

  const LicenseErrorState({required this.message, this.error});

  @override
  List<Object?> get props => [message, error];
}

class LicenseValidState extends LicenseState {
  final License license;

  const LicenseValidState({required this.license});

  @override
  List<Object?> get props => [license];
}

class LicenseInvalidState extends LicenseState {
  final String message;
  final License? license;

  const LicenseInvalidState({required this.message, this.license});

  @override
  List<Object?> get props => [message, license];
}

class LicenseExpiredState extends LicenseState {
  final License license;

  const LicenseExpiredState({required this.license});

  @override
  List<Object?> get props => [license];
}
