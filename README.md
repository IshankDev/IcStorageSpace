# ic_storage_space

Flutter storage space plugin for Android, IOS and MacOS

## Installation

Add `ic_storage_space` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/packages-and-plugins/using-packages)

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:ic_storage_space/ic_storage_space.dart';


class MyWidget extends StatelessWidget {

  Future<String> getStorageSpaceInfo() async {
    int totalSpace = await IcStorageSpace.getTotalDiskSpaceInBytes;
    int freeSpace = await IcStorageSpace.getFreeDiskSpaceInBytes;
    int usedSpace = await IcStorageSpace.getUsedDiskSpaceInBytes;

    
    return 'Total Space - $totalSpace\n\nFree Space - $freeSpace\n\nUsed Space - $usedSpace';
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Storage Space example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
```

