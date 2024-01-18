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
              return space
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


    func pathBytes(path: String) -> Int64 {
        print("storage_space_swift pathBytes \(path)")
        let fileManager = FileManager.default
        var totalSize: Int64 = 0

        guard let enumerator = fileManager.enumerator(atPath: path) else {
            return 0
        }
        for case let file as String in enumerator {
            let filePath = (path as NSString).appendingPathComponent(file)
            do {
                let attributes = try fileManager.attributesOfItem(atPath: filePath)
                if let fileSize = attributes[.size] as? Int64 {
                    totalSize += fileSize
                }
            } catch {
                print("storage_space_swift Failed to calculate file size: \(error.localizedDescription)")
            }
        }
        return totalSize
    }

   private func storageStats() -> [String: Int64] {
        // FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.path
        // 等价于 NSHomeDirectory() + "/Library/Caches"
        // NSHomeDirectory()  为  home /Users/leeyi/Library/Containers/pub.imboy.macos/Data
        print("storage_space_swift Bundle.main.bundlePath: \(Bundle.main.bundlePath)")
        let stats: [String: Int64] = [
            "appBytes": pathBytes(path: Bundle.main.bundlePath as String),
            "cacheBytes": pathBytes(path: NSHomeDirectory() + "/Library/Caches"),
            "dataBytes": pathBytes(path: NSHomeDirectory() + "/Documents"),
            "appCacheBytes": pathBytes(path: NSHomeDirectory() + "/Library/Caches"),
            //"cacheBytes2": pathBytes(path: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.path),
            //"dataBytes2": pathBytes(path: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path),
        ]
        print("storage_space_swift stats: \(stats)")
        return stats
    }

  private func clearAllCache() -> Bool {
    deleteFiles(path: NSHomeDirectory() + "/Library/Caches")
    return true
  }

  private func deleteFiles(path: String) -> Bool {
    print("storage_space_swift deleteFiles \(path)")
    let fileManager = FileManager.default
    do {
        let files = try fileManager.contentsOfDirectory(atPath: path)
        for file in files {
            let filePath = (path as NSString).appendingPathComponent(file)
            try fileManager.removeItem(atPath: filePath)
        }
        return true // 删除成功
    } catch {
        print("Error deleting files: \(error)")
        return false // 删除失败
    }
  }

  private func pathList(path: String) -> [String] {
      print("storage_space_swift pathList path \(path)")
      return getAllFilesAndDirectoriesRecursively(in: path)
  }

  private func getAllFilesAndDirectoriesRecursively(in directoryPath: String) -> [String] {
        var fileList = [String]()

        if let enumerator = FileManager.default.enumerator(atPath: directoryPath) {
            while let subPath = enumerator.nextObject() as? String {
                let fullPath = (directoryPath as NSString).appendingPathComponent(subPath)

                // 判断是否为目录
                var isDirectory: ObjCBool = false
                FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDirectory)

                if isDirectory.boolValue {
                    // 递归调用以获取子目录中的文件和目录
                    let subList = getAllFilesAndDirectoriesRecursively(in: fullPath)
                    fileList.append(contentsOf: subList)
                } else {
                    // 是文件
                    fileList.append(fullPath)
                }
            }
        }
        return fileList
  }
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

    switch call.method {
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
    case "getTotalDiskSpaceInBytes":
      result(totalDiskSpaceInBytes())
    case "getFreeDiskSpaceInBytes":
      result(freeDiskSpaceInBytes())
    case "storageStats":
      result(storageStats())
    case "clearAllCache":
        result(clearAllCache())
    case "homeDirectory":
        result(NSHomeDirectory())
    case "deletePath":
        guard let arguments = call.arguments as? [String: Any?] else {
            return
        }
        let path: String = arguments["path"] as! String
        let home = NSHomeDirectory() as String
        result(deleteFiles(path: path))
    case "pathBytes":
        guard let arguments = call.arguments as? [String: Any?] else {
            return
        }
        let path: String = arguments["path"] as! String
        result(pathBytes(path: path))
    case "pathList":
        guard let arguments = call.arguments as? [String: Any?] else {
            return
        }
        let path: String = arguments["path"] as! String
        result(pathList(path: path))
    default:
      result(FlutterMethodNotImplemented)
    }
  }


}
