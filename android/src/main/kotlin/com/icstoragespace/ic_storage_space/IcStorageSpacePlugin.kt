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

import android.content.Context
import android.os.storage.StorageManager
import android.app.usage.StorageStats
import android.app.usage.StorageStatsManager
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
            "getTotalDiskSpaceInBytes" -> result.success( getTotalDiskSpaceInBytes())
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
}
