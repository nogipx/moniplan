// Conditional exports for platform-specific UniversalDatabaseOpener implementations.
// Chooses native implementation when dart:io available, web implementation when js_interop available.

export 'universal_database_opener_unsupported.dart'
    if (dart.library.io) 'universal_database_opener_native.dart'
    if (dart.library.js_interop) 'universal_database_opener_web.dart';
