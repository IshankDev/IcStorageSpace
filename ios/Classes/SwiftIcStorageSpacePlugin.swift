import Flutter
import UIKit

public class SwiftIcStorageSpacePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "ic_storage_space", binaryMessenger: registrar.messenger())
    let instance = SwiftIcStorageSpacePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
     switch call.method {
        case "getTotalDiskSpaceInBytes":
            result(UIDevice.current.totalDiskSpaceInBytes)
        case "getFreeDiskSpaceInBytes":
            result(UIDevice.current.freeDiskSpaceInBytes)
        case "storageStats":
            result(UIDevice.current.storageStats)
        case "clearAllCache":
            result(UIDevice.current.clearAllCache)
        case "homeDirectory":
            result(NSHomeDirectory())
        case "deletePath":
            guard let arguments = call.arguments as? [String: Any?],
                  let path = arguments["path"] as? String else {
                return
            }
            print("storage_space_swift deletePath arguments \(arguments)")
            result(UIDevice.current.deleteFiles(path: path))
        case "pathBytes":
            guard let arguments = call.arguments as? [String: Any?],
                  let path = arguments["path"] as? String else {
                return
            }
            print("storage_space_swift pathBytes arguments \(arguments)")
            result(UIDevice.current.pathBytes(path: path))
        case "pathList":
            guard let arguments = call.arguments as? [String: Any?],
                  let path = arguments["path"] as? String else {
                return
            }
            print("storage_space_swift pathList arguments \(arguments)")
            result(UIDevice.current.pathList(path: path))
        default:
            result(0.0)
        }
    result("iOS " + UIDevice.current.systemVersion)
  }
}

extension UIDevice {

    //MARK: Get raw value
    var totalDiskSpaceInBytes:Int64 {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
            let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value else { return 0 }
        return space
    }

    /*
     Total available capacity in bytes for "Important" resources, including space expected to be cleared by purging non-essential and cached resources. "Important" means something that the user or application clearly expects to be present on the local system, but is ultimately replaceable. This would include items that the user has explicitly requested via the UI, and resources that an application requires in order to provide functionality.
     Examples: A video that the user has explicitly requested to watch but has not yet finished watching or an audio file that the user has requested to download.
     This value should not be used in determining if there is room for an irreplaceable resource. In the case of irreplaceable resources, always attempt to save the resource regardless of available capacity and handle failure as gracefully as possible.
     */
    var freeDiskSpaceInBytes:Int64 {
        if #available(iOS 11.0, *) {
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

    var storageStats: [String: Int64] {
        // FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.path
        // 等价于 NSHomeDirectory() + "/Library/Caches"
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

    var clearAllCache: Bool {
        deleteFiles(path: NSHomeDirectory() + "/Library/Caches")
        return true
    }

    func deleteFiles(path: String) -> Bool {
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
    func pathList(path: String) -> [String] {
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
}


