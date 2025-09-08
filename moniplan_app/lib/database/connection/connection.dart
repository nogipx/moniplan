// Conditional exports for platform-specific UniversalDatabaseOpener implementations.
// Chooses native implementation when dart:io available, web implementation when js_interop available.

export 'connection_unsupported.dart'
    if (dart.library.io) 'connection_native.dart'
    if (dart.library.js_interop) 'connection_web.dart';
