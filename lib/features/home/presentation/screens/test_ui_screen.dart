import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Serves Flutter assets over a local HTTP server so the WebView can use
/// XHR to load .glb files (file:// XHR is blocked on iOS WKWebView).
class _AssetServer {
  HttpServer? _server;
  int get port => _server?.port ?? 0;

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server!.listen(_handle);
  }

  Future<void> _handle(HttpRequest request) async {
    var path = request.uri.path;
    if (path == '/') path = '/aangan_3d.html';

    final assetPath = 'assets/html${path}';
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

class TestUIScreen extends StatefulWidget {
  const TestUIScreen({super.key});

  @override
  State<TestUIScreen> createState() => _TestUIScreenState();
}

class _TestUIScreenState extends State<TestUIScreen> {
  late final WebViewController _controller;
  final _assetServer = _AssetServer();

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0A0509));
    _startServer();
  }

  Future<void> _startServer() async {
    await _assetServer.start();
    _controller.loadRequest(
      Uri.parse('http://localhost:${_assetServer.port}/'),
    );
  }

  @override
  void dispose() {
    _assetServer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0509),
      body: WebViewWidget(controller: _controller),
    );
  }
}
