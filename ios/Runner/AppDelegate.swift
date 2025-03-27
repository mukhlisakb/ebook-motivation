import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    VideoThumbnailPlugin.register(with: self.registrar(forPlugin: "video_thumbnail_channel")!)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
