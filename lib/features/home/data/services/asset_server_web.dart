import 'package:flutter/services.dart';

/// Web implementation of AssetServer.
/// Since Flutter web handles assets natively, and WebView is handled differently,
/// this is mostly a mock implementation to satisfy the common interface.
class AssetServer {
  int get port => 0;

  Future<void> start() async {
    // No-op on web
  }

  Future<void> stop() async {
    // No-op on web
  }
}
