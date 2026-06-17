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

    // Handle image requests from the deities folder
    if (path.startsWith('/assets/images/deities/')) {
      try {
        // Remove the leading slash to match the asset path in pubspec.yaml
        final assetPath = path.substring(1);
        final data = await rootBundle.load(assetPath);
        request.response.headers
          ..set('Content-Type', 'image/png')
          ..set('Access-Control-Allow-Origin', '*');
        request.response.add(data.buffer.asUint8List());
        await request.response.close();
        return;
      } catch (e) {
        request.response.statusCode = 404;
        request.response.write('Not found');
        await request.response.close();
        return;
      }
    }

    // Handle audio requests from the sounds folder
    if (path.startsWith('/assets/sounds/')) {
      try {
        final assetPath = path.substring(1);
        final data = await rootBundle.load(assetPath);
        final isWav = path.endsWith('.wav');
        request.response.headers
          ..set('Content-Type', isWav ? 'audio/wav' : 'audio/mpeg')
          ..set('Access-Control-Allow-Origin', '*');
        request.response.add(data.buffer.asUint8List());
        await request.response.close();
        return;
      } catch (e) {
        request.response.statusCode = 404;
        request.response.write('Not found');
        await request.response.close();
        return;
      }
    }

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
