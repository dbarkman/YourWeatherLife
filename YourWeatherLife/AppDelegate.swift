//
//  AppDelegate.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/20/22.
//

import Foundation

import UIKit
import Mixpanel

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    
    Mixpanel.initialize(token: "f8ba28b7e92443cbc4c9bc9cda390d8d")
    
    return true
  }
}
