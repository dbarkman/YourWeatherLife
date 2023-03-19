//
//  AppDelegate.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/20/22.
//

import UIKit
import OSLog
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "AppDelegate")
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    
    let homeDir = NSHomeDirectory();
    logger.debug("home location: \(homeDir)")
    
    //future notifications framework
    if UserDefaults.standard.string(forKey: "distinctId") == nil {
      Task {
        await AsyncAPI.shared.saveToken(token: "", debug: 0)
      }
    }
    
    FirebaseApp.configure()
    
    Review.requestReview()

    return true
  }
}
