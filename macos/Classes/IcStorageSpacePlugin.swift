import Cocoa
import FlutterMacOS

public class IcStorageSpacePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "ic_storage_space", binaryMessenger: registrar.messenger)
    let instance = IcStorageSpacePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

   private func totalDiskSpaceInBytes() -> Int64 {
      guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
          let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value else { return 0 }
      return space
    }

    private func freeDiskSpaceInBytes() -> Int64 {
      if #available(macOS 10.13, *) {
          if let space = try? URL(fileURLWithPath: NSHomeDirectory() as String).resourceValues(forKeys: [URLResourceKey.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage {
              return space ?? 0
          } else {
              return 0
          }
      } else {
          if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
          let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value {
              return freeSpace
          } else {
              return 0
          }
      }
    }


  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
    case "getTotalDiskSpaceInBytes":
      result(totalDiskSpaceInBytes())
    case "getFreeDiskSpaceInBytes":
      result(freeDiskSpaceInBytes())
    default:
      result(FlutterMethodNotImplemented)
    }
  }


}
