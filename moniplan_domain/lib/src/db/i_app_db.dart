import 'dart:io';

typedef IAppDbFactory = IAppDb Function();

abstract class IAppDb {
  Future<void> close();

  Future<void> openDefault();

  Future<void> overrideDefaultFromFile({
    required File newDbFile,
    String encryptKey = '',
  });

  Future<void> openTemporaryFromFile({
    required File dbFile,
    String encryptKey = '',
  });
}
