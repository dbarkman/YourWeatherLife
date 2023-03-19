//
//  AppDelegate.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/20/22.
//

import Foundation
import OSLog
import UIKit
import Mixpanel

class AppDelegate: NSObject, UIApplicationDelegate {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "AppDelegate")
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    
    let homeDir = NSHomeDirectory();
    logger.debug("home location: \(homeDir)")
    
    return true
  }
}
