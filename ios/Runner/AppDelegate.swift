import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // TODO: Figure out how to get this from the environment or using a secret manager
    GMSServices.provideAPIKey("AIzaSyD9DKNhJbRu_uX3QeBcwj9DS0jxUkbSIUY") 

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
