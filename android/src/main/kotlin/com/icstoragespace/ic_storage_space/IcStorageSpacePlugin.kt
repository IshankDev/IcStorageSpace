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

/** IcStorageSpacePlugin */
class IcStorageSpacePlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "ic_storage_space")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "getFreeDiskSpaceInBytes" -> result.success(getFreeDiskSpaceInBytes())
            "getTotalDiskSpaceInBytes" -> result.success(getTotalDiskSpaceInBytes())
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

    private fun getTotalDiskSpaceInBytes(): Long {
        val stat = StatFs(Environment.getExternalStorageDirectory().path)

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.JELLY_BEAN_MR2)
            return stat.blockSizeLong * stat.blockCountLong
        else
            return stat.blockSize.toLong() * stat.blockCount.toLong()
    }


}
