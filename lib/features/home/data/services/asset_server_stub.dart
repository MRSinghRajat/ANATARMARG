import 'package:flutter/services.dart';

/// Stub when dart:io is not available (e.g. web).
class AssetServer {
  int get port => 0;

  Future<void> start() async {}

  Future<void> stop() async {}
}
