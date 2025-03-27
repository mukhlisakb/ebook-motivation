import Flutter  
import UIKit  
import AVFoundation  

public class VideoThumbnailPlugin: NSObject, FlutterPlugin {  
    public static func register(with registrar: FlutterPluginRegistrar) {  
        let channel = FlutterMethodChannel(name: "video_thumbnail_channel", binaryMessenger: registrar.messenger())  
        let instance = VideoThumbnailPlugin()  
        registrar.addMethodCallDelegate(instance, channel: channel)  
    }  

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {  
        switch call.method {  
        case "getVideoThumbnail":  
            guard let args = call.arguments as? [String: Any],  
                  let videoPath = args["videoPath"] as? String else {  
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Video path is required", details: nil))  
                return  
            }  
            
            let maxWidth = args["maxWidth"] as? Int ?? 400  
            let maxHeight = args["maxHeight"] as? Int ?? 400  
            let quality = args["quality"] as? Int ?? 75  
            
            do {  
                let asset = AVURLAsset(url: URL(fileURLWithPath: videoPath))  
                let generator = AVAssetImageGenerator(asset: asset)  
                generator.appliesPreferredTrackTransform = true  
                generator.maximumSize = CGSize(width: CGFloat(maxWidth), height: CGFloat(maxHeight))  
                
                let cgImage = try generator.copyCGImage(at: CMTime.zero, actualTime: nil)  
                let image = UIImage(cgImage: cgImage)  
                
                guard let data = image.jpegData(compressionQuality: CGFloat(quality) / 100.0) else {  
                    result(FlutterError(code: "THUMBNAIL_ERROR", message: "Failed to convert image", details: nil))  
                    return  
                }  
                
                result(FlutterStandardTypedData(bytes: data))  
            } catch {  
                result(FlutterError(code: "THUMBNAIL_ERROR", message: error.localizedDescription, details: nil))  
            }  
        default:  
            result(FlutterMethodNotImplemented)  
        }  
    }  
}  