import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  /// Returns whether the application is running in a web browser.
  static bool get isWeb => kIsWeb;

  /// Returns whether the application is running on a mobile platform (Android/iOS).
  static bool get isMobile => !kIsWeb;

  /// Dynamically determines the backend API base URL.
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000'; // Web base URL
    } else {
      return 'http://10.0.2.2:3000'; // Mobile Emulator loopback URL
    }
  }

  /// Helper to build API endpoints.
  static Uri apiUri(String path) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$cleanPath');
  }
}
