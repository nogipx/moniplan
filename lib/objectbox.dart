import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:permission_handler/permission_handler.dart';

class LocalDB {
  /// The Store of this app.
  late final Isar store;

  LocalDB._create(this.store) {
    // Add any additional setup code, e.g. build queries.
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<LocalDB> create() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      throw Exception('Cannot open database because of permission');
    }

    final extDir = await getExternalStorageDirectory();
    if (extDir == null) {
      throw Exception('Cannot access directory');
    }
    final dir = Directory("${extDir.path}/moniplan");

    if (!dir.existsSync()) {
      dir.createSync();
    }

    final docDir = await getApplicationDocumentsDirectory();

    final store = await Isar.open(
      [
        PaymentComposedDaoIsarSchema,
        PaymentPlannerDaoIsarSchema,
      ],
      // directory: p.join(dir.path, "obx-example"),
      directory: docDir.path,
    );

    return LocalDB._create(store);
  }
}
//
// Future<Directory> getExternalDocumentPath() async {
//   final status = await Permission.storage.status;
//   if (!status.isGranted) {
//     await Permission.storage.request();
//   }
//   Directory directory = Directory("");
//   if (Platform.isAndroid) {
//     directory = Directory("/storage/emulated/0/Downloads");
//   } else {
//     directory = await getApplicationDocumentsDirectory();
//   }
//
//   final exPath = directory.path;
//   return Directory(exPath);
// }
