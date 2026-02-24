// IO implementation: used for mobile (iOS/Android).
import 'dart:io';

String get pushPlatform => Platform.isIOS ? 'ios' : (Platform.isAndroid ? 'android' : 'unknown');
