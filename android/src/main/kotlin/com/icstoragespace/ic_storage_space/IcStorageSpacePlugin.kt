package com.icstoragespace.ic_storage_space

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import android.os.Environment
import android.os.StatFs
import android.os.Process

import android.content.Context
import android.os.storage.StorageManager
import android.app.usage.StorageStats
import android.app.usage.StorageStatsManager

import java.io.File
import java.io.IOException
import java.util.UUID

/** IcStorageSpacePlugin */
class IcStorageSpacePlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.getApplicationContext()
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "ic_storage_space")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "getFreeDiskSpaceInBytes" -> result.success(getFreeDiskSpaceInBytes())
            "getTotalDiskSpaceInBytes" -> result.success(getTotalDiskSpaceInBytes())
            "storageStats" -> result.success(storageStats())
            "clearAllCache" -> result.success(clearAllCache())
            "homeDirectory" -> result.success(Environment.getExternalStorageDirectory().absolutePath)
            "deletePath" -> result.success(deletePath(call.argument("path")))
            "pathBytes" -> result.success(pathBytes(call.argument("path")))
            "pathList" -> result.success(pathList(call.argument("path")))
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun getFreeDiskSpaceInBytes(): Long {
        val stat = StatFs(Environment.getExternalStorageDirectory().path)

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.JELLY_BEAN_MR2)
            return stat.blockSizeLong * stat.availableBlocksLong
        else
            return stat.blockSize.toLong() * stat.availableBlocks.toLong()
    }

    /**
     * A more accurate way to get Android storage space
     *  TODO: api compatibility is subject to rigorous testing （minAPI is 26?)
     *  https://gist.github.com/li-jkwok/e460a042326e8509ada9ec23ae677bdf
     */
    private fun getTotalDiskSpaceInBytes(): Long {
        val storageManager = context.getSystemService(Context.STORAGE_SERVICE) as StorageManager
        val storageStatsManager = context.getSystemService(Context.STORAGE_STATS_SERVICE) as StorageStatsManager
        val storageVolumes = storageManager.storageVolumes
        var totalBytes = 0L
        for (volume in storageVolumes) {
            val uuid = volume.uuid?.let { UUID.fromString(it) } ?: StorageManager.UUID_DEFAULT
            totalBytes += storageStatsManager.getTotalBytes(uuid)
        }
        return totalBytes.toLong()
    }

    /**
     * 获取当前应用的存储信息 Added in API level 26
     * Obtain storage information about the current application
     * start 8.0 Methods are no longer compatible with 7.0
     * https://developer.android.com/reference/android/app/usage/StorageStats#getDataBytes()
     */
    private fun storageStats(): Map<String, Long?> {
        var packageName = context.getPackageName()
        val storageManager = context.getSystemService(Context.STORAGE_SERVICE) as StorageManager
        val storageStatsManager = context.getSystemService(Context.STORAGE_STATS_SERVICE) as StorageStatsManager
        val storageVolumes = storageManager.storageVolumes
        //获取当前用户
        var user = Process.myUserHandle()
        var appBytes = 0L
        var cacheBytes = 0L
        var dataBytes = 0L
        for (volume in storageVolumes) {
            //检测到他是挂载状态的 并且是主要的那个一个
            if ("mounted".equals(volume.getState()) && volume.isPrimary()) {
                val uuid = volume.uuid?.let { UUID.fromString(it) } ?: StorageManager.UUID_DEFAULT
                var storageStats = storageStatsManager.queryStatsForPackage(uuid, packageName, user) as StorageStats
                // App 包括安装包
                appBytes += storageStats.getAppBytes()
                // 软件的缓存 (内部缓存 外部缓存 加code_cache 一起返回的)
                cacheBytes += storageStats.getCacheBytes()
                // 用户的数据
                dataBytes += storageStats.getDataBytes()
            }
        }
        val map: MutableMap<String, Long?> = mutableMapOf()
        map["cacheBytes"] = cacheBytes.toLong()
        map["dataBytes"] = dataBytes.toLong()
        map["appBytes"] = appBytes.toLong()
        return map
    }

    private fun pathList(path: String?): List<String> {
        if (path.isNullOrEmpty()) {
            return getAllFilesAndDirectories(context.filesDir)
        } else {
            return getAllFilesAndDirectories(File(path))
        }
    }

    /**
     * 获取特定目录下面所有的目录及文件 路径列表
     */
    private fun getAllFilesAndDirectories(directory: File): List<String> {
        val filePaths = mutableListOf<String>()
        if (directory.isDirectory) {
            val files = directory.listFiles()

            if (files != null) {
                for (file in files) {
                    if (file.isFile) {
                        filePaths.add(file.absolutePath)
                    } else if (file.isDirectory) {
                        filePaths.addAll(getAllFilesAndDirectories(file))
                    }
                }
            }
        }
        return filePaths;
    }

    private fun pathBytes(path: String?): Long? {
        if (path.isNullOrEmpty()) {
            return null
        }
        return  fileBytes(File(path))
    }

    private fun fileBytes(f: File): Long {
        var size: Long = 0
        if (f.isFile) {
            size += f.length()
        } else if (f.isDirectory) {
            val files = f.listFiles()
            if (files != null) {
                for (file in files) {
                    size += if (file.isFile) file.length() else fileBytes(file)
                }
            }
        }
        return size
    }

    private fun clearAllCache(): Boolean {
        try {
            val cacheDir = context.cacheDir
            // val filesDir = context.filesDir

            // 清除内部缓存目录中的文件
            deleteFiles(cacheDir)
            deleteFiles(context.getCodeCacheDir())

            // 清除内部文件目录中的文件
            // deleteFiles(filesDir)

            // 如果应用程序有外部缓存目录，也可以清除外部缓存目录中的文件
            if (android.os.Environment.getExternalStorageState() == android.os.Environment.MEDIA_MOUNTED) {
                val externalCacheDir = context.externalCacheDir
                if (externalCacheDir != null) {
                    deleteFiles(externalCacheDir)
                }
            }

            return true // 清理缓存成功
        } catch (e: Exception) {
            e.printStackTrace()
            return false // 清理缓存失败
        }
    }

    private fun deletePath(path: String?): Boolean {
        if (path.isNullOrEmpty()) {
            return false
        }
        val dir = File(path)
        deleteFiles(dir)
        return true
    }

    private fun deleteFiles(dir: File): Boolean {
        println("deleteFiles: ${dir.path}") // 打印列表
        try {
            if (dir.isDirectory) {
                val children = dir.list()
                children?.forEach { fileName ->
                    val file = File(dir, fileName)
                    // 递归删除子目录和文件
                    deleteFiles(file)
                }
            }
            // 删除当前目录
            dir.delete()
            return true
        } catch (e: Exception) {
            e.printStackTrace()
            return false // 清理缓存失败
        }
    }
}
