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
  }
  
  var body: some Scene {
    WindowGroup {
      Home()
    }
  }

}
