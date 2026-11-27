import Flutter
import UIKit
// This is required for calling FlutterLocalNotificationsPlugin.setPluginRegistrantCallback method.
import flutter_local_notifications
import airbridge_flutter_sdk


/// Uses the UIScene lifecycle (see SceneDelegate): the Flutter engine is
/// created with the scene's window, so plugins and app channels are set up in
/// `didInitializeImplicitFlutterEngine`, and opened links reach SceneDelegate.
@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  /// Retained for the app's lifetime — it owns the running Live Activity.
  private let timerLiveActivityBridge = TimerLiveActivityBridge()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // This is required to make any communication available in the action isolate.
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
        GeneratedPluginRegistrant.register(with: registry)
    }

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    let airbridgeAppName = Bundle.main.object(forInfoDictionaryKey: "AIRBRIDGE_APP_NAME") as? String ?? ""
    let airbridgeSdkToken = Bundle.main.object(forInfoDictionaryKey: "AIRBRIDGE_SDK_TOKEN") as? String ?? ""
    AirbridgeFlutter.initializeSDK(name: airbridgeAppName, token: airbridgeSdkToken)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    timerLiveActivityBridge.register(with: engineBridge.applicationRegistrar.messenger())
  }

  /// Links Airbridge tracks itself instead of handing them to Flutter.
  static func shouldHandleWithAirbridge(_ url: URL) -> Bool {
    let scheme = url.scheme?.lowercased() ?? ""
    let host = url.host?.lowercased() ?? ""
    return scheme == "webuddhist"
      || host == "join.webuddhist.com"
      || host.hasSuffix(".airbridge.io")
      || host.hasSuffix(".abr.ge")
  }
}
