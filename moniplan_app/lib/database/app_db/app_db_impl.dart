// SPDX-FileCopyrightText: 2025 Karim "nogipx" Mamatkazin <nogipx@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// Conditional export to select platform-specific AppDbImpl implementation
export 'app_db_impl_unsupported.dart'
    if (dart.library.io) 'app_db_impl_native.dart'
    if (dart.library.js_interop) 'app_db_impl_web.dart';
