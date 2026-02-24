import 'dart:io';

import 'package:flutter/services.dart';

/// Serves Flutter assets over a local HTTP server so WebView can load .glb
/// (file:// XHR is blocked on iOS WKWebView).
class AssetServer {
  HttpServer? _server;
  int get port => _server?.port ?? 0;

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server!.listen(_handle);
  }

  Future<void> _handle(HttpRequest request) async {
    var path = request.uri.path;
    if (path == '/') path = '/aangan_3d.html';

    final assetPath = 'assets/html$path';
    try {
      if (path.endsWith('.glb') || path.endsWith('.gltf')) {
        final data = await rootBundle.load(assetPath);
        request.response.headers
          ..set('Content-Type', 'model/gltf-binary')
          ..set('Access-Control-Allow-Origin', '*');
        request.response.add(data.buffer.asUint8List());
      } else {
        final content = await rootBundle.loadString(assetPath);
        request.response.headers
          ..set('Content-Type', 'text/html; charset=utf-8')
          ..set('Access-Control-Allow-Origin', '*');
        request.response.write(content);
      }
    } catch (_) {
      request.response.statusCode = 404;
      request.response.write('Not found');
    }
    await request.response.close();
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }
}
