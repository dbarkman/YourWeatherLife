//
//  YourWeatherLifeApp.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/19/22.
//

import SwiftUI
import OSLog
import Mixpanel

@main
struct YourWeatherLifeApp: App {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "YourWeatherLifeApp")
  
  //  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  var globalViewModel = GlobalViewModel.shared
  
  init() {
    Mixpanel.initialize(token: "f8ba28b7e92443cbc4c9bc9cda390d8d")
    let homeDir = NSHomeDirectory();
    logger.debug("home location: \(homeDir)")
    upgradeSteps()
  }
  
  private func upgradeSteps() {
    let appVersion = globalViewModel.fetchAppVersionNumber()
    let buildNumber = globalViewModel.fetchBuildNumber()
    let currentVersion = "\(appVersion)-\(buildNumber)"
    logger.debug("App Version: \(appVersion)-\(buildNumber)")
  }
  
  private func updateiCloudAccountStatus() async {
    let accountStatus = await CloudKitManager.shared.requestAccountStatus()
    if FileManager.default.ubiquityIdentityToken == nil || accountStatus != .available {
      UserDefaults.standard.set(true, forKey: "userNotLoggedIniCloud")
    }
  }
  
  private func updateLocationMethod() {
    let authorizationStatus = LocationViewModel.shared.authorizationStatus
    if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
      UserDefaults.standard.set(true, forKey: "automaticLocation")
    } else {
      UserDefaults.standard.set(false, forKey: "automaticLocation")
      guard let _ = UserDefaults.standard.string(forKey: "manualLocationData") else {
        UserDefaults.standard.set("98034", forKey: "manualLocationData")
        return
      }
    }
  }

  var body: some Scene {
    WindowGroup {
      if UserDefaults.standard.string(forKey: "currentVersion") != nil && UserDefaults.standard.string(forKey: "currentVersion") != "1.1-2023010501" {
        AppCrashing()
      } else {
        Home()
      }
    }
  }

}
