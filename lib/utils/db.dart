import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../objectbox.g.dart';

late Store store;

class ObjectBox {
  late final Store _store;

  ObjectBox._create(this._store) {
    store = _store;
  }

  static Future<ObjectBox> init() async {
    // check what platform we're running on
    if (kDebugMode) {
      await _showAllPath();
    }
    String dbPath;
    switch (Platform.operatingSystem) {
      case 'windows':
        dbPath = join(
            await getApplicationSupportDirectory().then((value) => value.path),
            'objectbox');
        break;
      case 'android':
      default:
        dbPath = join(
            await getExternalStorageDirectory()
                .then((value) => value?.path)
                .then((value) {
              if (value == null) {
                return getApplicationSupportDirectory()
                    .then((value) => value.path);
              } else {
                return value;
              }
            }),
            'objectbox');
        break;
    }
    final store_ = await openStore(directory: dbPath);
    return ObjectBox._create(store_);
  }

  static _showAllPath() async {
    // ignore: avoid_print
    print('Running on ${Platform.operatingSystem}');
    // ignore: avoid_print
    print('Temporary: ${await getTemporaryDirectory()}');
    // ignore: avoid_print
    print('Application Support: ${await getApplicationSupportDirectory()}');
    if (Platform.isIOS || Platform.isMacOS) {
      // ignore: avoid_print
      print('Application Library: ${await getLibraryDirectory()}');
    }
    // ignore: avoid_print
    print('Application Documents: ${await getApplicationDocumentsDirectory()}');
    if (Platform.isAndroid) {
      // ignore: avoid_print
      print('External Storage: ${await getExternalStorageDirectory()}');
      // ignore: avoid_print
      print(
          'External Cache Directories: ${await getExternalCacheDirectories()}');
      // ignore: avoid_print
      print(
          'External Storage Directories: ${await getExternalStorageDirectories()}');
    }
    if (!Platform.isAndroid && !Platform.isIOS) {
      // ignore: avoid_print
      print('Downloads Directory: ${await getDownloadsDirectory()}');
    }
  }
}
