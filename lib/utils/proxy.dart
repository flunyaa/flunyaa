import 'package:flunyaa/data/proxy.dart';
import 'package:flunyaa/objectbox.g.dart';
import 'package:flunyaa/utils/db.dart';

String loadSelectedProxy() {
  final proxyBox = store.box<ProxyConfiguration>();
  final selectedProxy = proxyBox
      .query(ProxyConfiguration_.selected.equals(true))
      .build()
      .findFirst();
  if (selectedProxy == null) {
    return 'DIRECT';
  } else {
    return '${selectedProxy.type} ${selectedProxy.host}:${selectedProxy.port}';
  }
}
