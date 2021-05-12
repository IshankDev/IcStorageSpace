import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ic_storage_space/ic_storage_space.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _totalSpace = 0;
  int _freeSpace = 0;
  int _usedSpace = 0;
  int forMB = (1024 * 1024);

  @override
  void initState() {
    super.initState();
  }

  Future<String> getStorageSpaceInfo() async {
    int totalSpace = await IcStorageSpace.getTotalDiskSpaceInBytes;
    int freeSpace = await IcStorageSpace.getFreeDiskSpaceInBytes;
    int usedSpace = await IcStorageSpace.getUsedDiskSpaceInBytes;

    setState(() {
      _totalSpace = (totalSpace / forMB).round();
      _freeSpace = (freeSpace / forMB).round();
      _usedSpace = (usedSpace / forMB).round();
    });

    return 'Total Space - $totalSpace\n\nFree Space - $freeSpace\n\nUsed Space - $usedSpace';
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
            ElevatedButton(
              onPressed: () async {
                await getStorageSpaceInfo();
              },
              child: Text('Get Storage Info'),
            )
          ],
        ),
      ),
    );
  }
}
