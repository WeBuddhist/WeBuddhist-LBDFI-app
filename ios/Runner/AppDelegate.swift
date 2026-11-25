import Flutter
import UIKit
// This is required for calling FlutterLocalNotificationsPlugin.setPluginRegistrantCallback method.
import flutter_local_notifications
import airbridge_flutter_sdk

// The app uses the UIScene life cycle (see UIApplicationSceneManifest in Info.plist).
// iOS 27 refuses to launch apps built with the iOS 27 SDK that don't, so plugins are
// registered when Flutter creates its engine, and URLs arrive through SceneDelegate.
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
}

/// Receives the URLs and universal links that `application(_:open:)` and
/// `application(_:continue:)` got before the scene life cycle. Airbridge links go to
/// Airbridge; everything else goes on to Flutter and its plugins.
class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    for context in connectionOptions.urlContexts where Self.isAirbridge(context.url) {
      AirbridgeFlutter.trackDeeplink(url: context.url)
    }
    for activity in connectionOptions.userActivities {
      if let url = activity.webpageURL, Self.isAirbridge(url) {
        AirbridgeFlutter.trackDeeplink(userActivity: activity)
      }
    }
  }

  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    let airbridge = URLContexts.filter { Self.isAirbridge($0.url) }
    for context in airbridge {
      AirbridgeFlutter.trackDeeplink(url: context.url)
    }
    let others = URLContexts.subtracting(airbridge)
    if !others.isEmpty {
      super.scene(scene, openURLContexts: others)
    }
  }

  override func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
    if let url = userActivity.webpageURL, Self.isAirbridge(url) {
      AirbridgeFlutter.trackDeeplink(userActivity: userActivity)
      return
    }
    super.scene(scene, continue: userActivity)
  }

  private static func isAirbridge(_ url: URL) -> Bool {
    let scheme = url.scheme?.lowercased() ?? ""
    let host = url.host?.lowercased() ?? ""
    return scheme == "webuddhist"
      || host == "join.webuddhist.com"
      || host.hasSuffix(".airbridge.io")
      || host.hasSuffix(".abr.ge")
  }
}
