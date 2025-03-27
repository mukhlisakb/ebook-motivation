package com.mukhlisakb.ebookapp  

import android.graphics.Bitmap  
import android.media.MediaMetadataRetriever  
import io.flutter.embedding.engine.plugins.FlutterPlugin  
import io.flutter.plugin.common.MethodCall  
import io.flutter.plugin.common.MethodChannel  
import java.io.ByteArrayOutputStream  

class VideoThumbnailPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {  
    private lateinit var channel: MethodChannel  

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {  
        channel = MethodChannel(binding.binaryMessenger, "video_thumbnail_channel")  
        channel.setMethodCallHandler(this)  
    }  

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {  
        when (call.method) {  
            "getVideoThumbnail" -> {  
                val videoPath = call.argument<String>("videoPath")  
                val maxWidth = call.argument<Int>("maxWidth") ?: 400  
                val maxHeight = call.argument<Int>("maxHeight") ?: 400  
                val quality = call.argument<Int>("quality") ?: 75  

                if (videoPath == null) {  
                    result.error("INVALID_ARGUMENT", "Video path is required", null)  
                    return  
                }  

                try {  
                    val retriever = MediaMetadataRetriever()  
                    retriever.setDataSource(videoPath)  
                    
                    val bitmap = retriever.frameAtTime  
                    if (bitmap != null) {  
                        val resizedBitmap = Bitmap.createScaledBitmap(bitmap, maxWidth, maxHeight, true)  
                        val stream = ByteArrayOutputStream()  
                        resizedBitmap.compress(Bitmap.CompressFormat.JPEG, quality, stream)  
                        val byteArray = stream.toByteArray()  
                        result.success(byteArray)  
                    } else {  
                        result.error("THUMBNAIL_ERROR", "Failed to get thumbnail", null)  
                    }  
                    retriever.release()  
                } catch (e: Exception) {  
                    result.error("THUMBNAIL_ERROR", e.message, null)  
                }  
            }  
            else -> result.notImplemented()  
        }  
    }  

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {  
        channel.setMethodCallHandler(null)  
    }  
}  