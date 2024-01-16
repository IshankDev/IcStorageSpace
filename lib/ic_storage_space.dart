
import 'dart:async';

import 'package:flutter/services.dart';

class IcStorageSpace {
  static const MethodChannel _channel =
      const MethodChannel('ic_storage_space');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<int> get getTotalDiskSpaceInBytes async {
    final int totalDiskSpace = await _channel.invokeMethod('getTotalDiskSpaceInBytes');
    return totalDiskSpace;
  }

  static Future<int> get getFreeDiskSpaceInBytes async {
    final int freeDiskSpace = await _channel.invokeMethod('getFreeDiskSpaceInBytes');
    return freeDiskSpace;
  }

  static Future<Map<String, int>> get storageStats async {
    return await _channel.invokeMethod('storageStats');
  }


  static Future<int> get getUsedDiskSpaceInBytes async {
    return (await getTotalDiskSpaceInBytes) - (await getFreeDiskSpaceInBytes);
  }

}
