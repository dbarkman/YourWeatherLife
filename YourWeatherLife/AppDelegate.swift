//
//  AppDelegate.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/20/22.
//

import UIKit
import Mixpanel
import FirebaseCore
import OSLog

class AppDelegate: NSObject, UIApplicationDelegate {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "AppDelegate")
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    
    let homeDir = NSHomeDirectory();
    logger.debug("home location: \(homeDir)")
    
    AppDelegate.register(in: application, using: self)

    FirebaseApp.configure()
    
    Review.requestReview()

    return true
  }

  static func register(in application: UIApplication, using notificationDelegate: UNUserNotificationCenterDelegate? = nil) {
    let center = UNUserNotificationCenter.current()
    center.delegate = notificationDelegate
    center.requestAuthorization(options: [.sound, .alert], completionHandler: { granted, error in
      if error != nil {
        print("Notification request error: \(error?.localizedDescription ?? "")")
      } else if granted {
        DispatchQueue.main.async {
          application.registerForRemoteNotifications()
        }
      } else {
        if !UserDefaults.standard.bool(forKey: "notNewInstall") {
          Mixpanel.mainInstance().track(event: "Notifications Not Authorized")
          UserDefaults.standard.set(true, forKey: "notNewInstall")
          UserDefaults.standard.set(false, forKey: "sendPush")
        }
      }
    })
  }
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      guard settings.authorizationStatus == .authorized else { return }
      if settings.alertSetting == .enabled {
        if !UserDefaults.standard.bool(forKey: "notNewInstall") {
          Mixpanel.mainInstance().track(event: "Notifications Authorized")
          UserDefaults.standard.set(true, forKey: "notNewInstall")
          UserDefaults.standard.set(true, forKey: "sendPush")
          UserDefaults.standard.set(false, forKey: "sendAll")
          UserDefaults.standard.set(false, forKey: "sendArea")
        }
        let token = deviceToken.reduce("") { $0 + String(format: "%02x", $1) }
        UserDefaults.standard.set(token, forKey: "apnsToken")
        
        self.logger.debug("APNs token: \(token)")
        
        var debug = 0
#if DEBUG
        debug = 1
#endif
        UserDefaults.standard.set(debug, forKey: "apnsDebug")

        Task {
          if UserDefaults.standard.string(forKey: "zone") == nil {
            await AsyncAPI.shared.getZoneId()
          }
          await AsyncAPI.shared.saveToken(token: token, debug: debug)
        }
      }
    }
  }
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    logger.error("APNs error: \(error)")
  }
  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
    GlobalViewModel.shared.selectedTab = 5
    NotificationCenter.default.post(name: .notificationReceivedEvent, object: nil)
    return .noData
  }
  
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
    return [.banner, .sound]
  }
}
