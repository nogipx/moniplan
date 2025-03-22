// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:equatable/equatable.dart';

abstract class LicenseEvent extends Equatable {
  const LicenseEvent();

  @override
  List<Object?> get props => [];
}

class LicenseAddedEvent extends LicenseEvent {
  final List<int> licenseBytes;

  const LicenseAddedEvent({required this.licenseBytes});

  @override
  List<Object?> get props => [licenseBytes];
}

class LicenseLoadedEvent extends LicenseEvent {
  const LicenseLoadedEvent();
}

class LicenseUpdatedEvent extends LicenseEvent {
  final List<int> licenseBytes;

  const LicenseUpdatedEvent({required this.licenseBytes});

  @override
  List<Object?> get props => [licenseBytes];
}

class LicenseDeletedEvent extends LicenseEvent {
  const LicenseDeletedEvent();
}

class LicenseStatusCheckedEvent extends LicenseEvent {
  const LicenseStatusCheckedEvent();
}
