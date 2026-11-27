import Flutter
import UIKit
import airbridge_flutter_sdk

/// The app's UIScene delegate. iOS 27 stops apps built with the iOS 27 SDK
/// that do not adopt the scene lifecycle at launch, so Runner uses one.
///
/// With scenes, iOS hands opened URLs and universal links to the scene, not
/// to the app delegate. Airbridge links are tracked here, as AppDelegate did
/// before; every other link goes on to Flutter and its plugins (app_links).
class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    // A link that launched the app arrives here instead of openURLContexts.
    let launchURLs =
      connectionOptions.urlContexts.map(\.url)
      + connectionOptions.userActivities.compactMap(\.webpageURL)
    if launchURLs.contains(where: AppDelegate.shouldHandleWithAirbridge) {
      AirbridgeFlutter.trackDeeplink(connectionOptions: connectionOptions)
    }
  }

  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    let airbridgeContexts = URLContexts.filter { AppDelegate.shouldHandleWithAirbridge($0.url) }
    if !airbridgeContexts.isEmpty {
      AirbridgeFlutter.trackDeeplink(openURLContexts: airbridgeContexts)
    }
    let otherContexts = URLContexts.subtracting(airbridgeContexts)
    if !otherContexts.isEmpty {
      super.scene(scene, openURLContexts: otherContexts)
    }
  }

  override func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
    if let url = userActivity.webpageURL, AppDelegate.shouldHandleWithAirbridge(url) {
      AirbridgeFlutter.trackDeeplink(userActivity: userActivity)
      return
    }
    super.scene(scene, continue: userActivity)
  }
}
