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
    logger.debug("App Version: \(appVersion), Build Number: \(buildNumber)")
    guard let currentVersionStored = UserDefaults.standard.object(forKey: "currentVersion") as? String else {
      //new install or update from 2022071102, let's check
      let defaultEventsLoaded = UserDefaults.standard.bool(forKey: "defaultEventsLoaded")
      if !defaultEventsLoaded {
        //new install, nothing to do
        Mixpanel.mainInstance().track(event: "New Install")
        logger.debug("New Install")
        UserDefaults.standard.set(currentVersion, forKey: "currentVersion")
        return
      } else {
        logger.debug("Not a new install")
      }
      //update from 2022071102 to current, got shit to do!
      Mixpanel.mainInstance().track(event: "Update from 2022071102")
      logger.debug("update from 2022071102")
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
      Mixpanel.mainInstance().track(event: "Upgrade from future version")
      logger.debug("May have some work to do.")
      UserDefaults.standard.set(currentVersion, forKey: "currentVersion")
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
