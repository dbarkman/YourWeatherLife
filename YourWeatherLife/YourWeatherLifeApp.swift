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
  
  init() {
    Mixpanel.initialize(token: "f8ba28b7e92443cbc4c9bc9cda390d8d")
    let homeDir = NSHomeDirectory();
    logger.debug("home location: \(homeDir)")
    upgradeSteps()
  }
  
  /*
   See if currentVersion is set at all, then follow one of three paths
   1. currentVersion not set at all, version: 2022071102
      - set location mode and manual data if needed
      - find current status of CoreData and make changes as necessary
   2. currentVersion is set but not the latest, version: future
      - do something
   3. currentVersion is set, latest version
      - do nothing
   */
  
  private func upgradeSteps() {
    let appVersion = GlobalViewModel.shared.fetchAppVersionNumber()
    let buildNumber = GlobalViewModel.shared.fetchBuildNumber()
    let currentVersion = "\(appVersion)-\(buildNumber)"
    logger.debug("App Version: \(appVersion), Build Number: \(buildNumber)")
    guard let currentVersionStored = UserDefaults.standard.object(forKey: "currentVersion") as? String else {
      //update from 2022071102 to current, got shit to do!
      logger.debug("currentVersion not yet set.")
      UserDefaults.standard.set(currentVersion, forKey: "currentVersion")
      
      Task {
        await updateiCloudAccountStatus()
        updateLocationMethod()
        let nextUpdate = Date(timeIntervalSince1970: 0)
        UserDefaults.standard.set(nextUpdate, forKey: "currentConditionsNextUpdate")
        UserDefaults.standard.set(nextUpdate, forKey: "forecastsNextUpdate")
      }

      return
    }
    logger.debug("CurrentVersion: \(currentVersionStored)")
    if currentVersionStored != currentVersion {
      //future released version
      logger.debug("May have some work to do.")
      UserDefaults.standard.set(currentVersion, forKey: "currentVersion")
    } else {
      //just opening the already installed app
      logger.debug("Same version, no update work to do.")
    }
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
      Home()
    }
  }
}
