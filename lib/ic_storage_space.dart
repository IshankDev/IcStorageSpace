import 'dart:async';

import 'package:flutter/services.dart';

class IcStorageSpace {
  static const MethodChannel _channel = const MethodChannel('ic_storage_space');

  static Future<String> get platformVersion async {
    return await _channel.invokeMethod('getPlatformVersion');
  }

  static Future<int> get getTotalDiskSpaceInBytes async {
    return await _channel.invokeMethod('getTotalDiskSpaceInBytes');
  }

  static Future<int> get getFreeDiskSpaceInBytes async {
    return await _channel.invokeMethod('getFreeDiskSpaceInBytes');
  }

  /// return {"appBytes":0, "cacheBytes":0, "dataBytes":0}
  static Future<Map<dynamic, dynamic>> get storageStats async {
    return await _channel.invokeMethod('storageStats');
  }

  static Future<int> get getUsedDiskSpaceInBytes async {
    return (await getTotalDiskSpaceInBytes) - (await getFreeDiskSpaceInBytes);
  }

  static Future<bool> clearAllCache() async {
    return await _channel.invokeMethod('clearAllCache');
  }

  static Future<bool> deletePath(String path) async {
    return await _channel.invokeMethod('deletePath', {'path': path});
  }
}
