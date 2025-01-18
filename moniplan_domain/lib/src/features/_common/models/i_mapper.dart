// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

abstract class IMapper<Domain, Dto> {
  Dto toDto(Domain data);
  Domain toDomain(Dto data);
}
