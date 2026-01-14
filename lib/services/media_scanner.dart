import 'dart:async';
import 'package:flutter/services.dart';

class MediaScanner {
  static const MethodChannel _channel = MethodChannel('media_scanner');

  /// 저장한 파일 경로를 갤러리에 반영
  static Future<void> scanFile(String path) async {
    try {
      await _channel.invokeMethod('scanFile', {'path': path});
    } catch (e) {
      print('MediaScanner scanFile 에러: $e');
    }
  }
}
