import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ic_storage_space/ic_storage_space.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  int _totalSpace = 0;
  int _freeSpace = 0;
  int _usedSpace = 0;
  int forMB = (1024 * 1024);

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    int totalSpace;
    int freeSpace;
    int usedSpace;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await IcStorageSpace.platformVersion;
      totalSpace = await IcStorageSpace.getTotalDiskSpaceInBytes;
      freeSpace = await IcStorageSpace.getFreeDiskSpaceInBytes;
      usedSpace = await IcStorageSpace.getUsedDiskSpaceInBytes;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      _totalSpace = (totalSpace / forMB).round();
      _freeSpace = (freeSpace / forMB).round();
      _usedSpace = (usedSpace / forMB).round();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text('Running on: $_platformVersion'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text('Total Space - $_totalSpace MB'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text('Free Space - $_freeSpace MB'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text('Used Space - $_usedSpace MB'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
