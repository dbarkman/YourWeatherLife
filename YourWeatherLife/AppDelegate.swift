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
    
//    Mixpanel.initialize(token: "f8ba28b7e92443cbc4c9bc9cda390d8d")

//    NSUbiquitousKeyValueStore.default.set("Earth", forKey: "planet")
//    if let planet = NSUbiquitousKeyValueStore.default.string(forKey: "planet") {
//      print("Planet is: \(planet)")
//    } else {
//      print("Planet could not be found. 😭")
//    }
    
    return true
  }
}
