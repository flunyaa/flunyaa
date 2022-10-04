import 'dart:convert';
import 'dart:io';

import 'package:flunyaa/utils/proxy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_socks_proxy/socks_proxy.dart';

class NyaaClient {
  String proxy = 'DIRECT';
  HttpClient http = createProxyHttpClient();
  static final NyaaClient _instance = NyaaClient();

  NyaaClient() {
    http.findProxy = (url) => loadSelectedProxy();
  }

  static void setProxy(String proxy) {
    _instance.proxy = proxy;
  }

  static Future<String> get(Uri url) async {
    return await _instance._get(url);
  }

  static Future<Uint8List> getBytes(Uri url) async {
    return await _instance._getBytes(url);
  }

  static Future<String> post(Uri url, {Map<String, String>? body}) async {
    return await _instance._post(url, body ?? {});
  }

  Future<String> _get(Uri url) async {
    final request = await http.getUrl(url);
    final response = await request.close();
    final result = await response.transform(utf8.decoder).join();
    return result;
  }

  // load image to bytes
  Future<Uint8List> _getBytes(Uri url) async {
    final request = await http.getUrl(url);
    final response = await request.close();
    final result = await response.toList();
    return Uint8List.fromList(result.expand((x) => x).toList());
  }

  Future<String> _post(Uri url, Map<String, String> body) async {
    final request = await http.postUrl(url);
    request.headers.contentType =
        ContentType('application', 'x-www-form-urlencoded');
    request.write(jsonEncode(body));
    final response = await request.close();
    final result = await response.transform(utf8.decoder).join();
    return result;
  }
}
