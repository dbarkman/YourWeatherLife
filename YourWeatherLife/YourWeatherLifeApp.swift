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
  
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  init() {
    Mixpanel.initialize(token: "f8ba28b7e92443cbc4c9bc9cda390d8d", trackAutomaticEvents: true)
    
    let appVersion = GlobalViewModel.shared.fetchAppVersionNumber()
    let buildNumber = GlobalViewModel.shared.fetchBuildNumber()
    let currentVersion = "\(appVersion)-\(buildNumber)"

    if let savedCurrentVersion = UserDefaults.standard.string(forKey: "currentVersion") {
      if savedCurrentVersion == "1.2.1-2023032401" || savedCurrentVersion == "1.2-2023031901" {
        logger.debug("current version: \(savedCurrentVersion)")
      }
    }

    UserDefaults.standard.set(currentVersion, forKey: "currentVersion")
  }
  
  var body: some Scene {
    WindowGroup {
      Tabs()
    }
  }
  
}
