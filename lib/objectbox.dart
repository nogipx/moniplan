import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:moniplan_core/moniplan_core.dart';
import 'package:permission_handler/permission_handler.dart';

class ObjectBox {
  /// The Store of this app.
  late final Store store;

  ObjectBox._create(this.store) {
    // Add any additional setup code, e.g. build queries.
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      throw Exception('Cannot open database because of permission');
    }

    final extDir = await getExternalStorageDirectory();
    if (extDir == null) {
      throw Exception('Cannot access directory');
    }
    final dir = Directory("${extDir.path}/moniplan_db");

    if (!dir.existsSync()) {
      dir.createSync();
    }

    final store = openStore(
      directory: p.join(dir.path, "obx-example"),
    );

    return ObjectBox._create(store);
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
