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

//  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  init() {
    Mixpanel.initialize(token: "f8ba28b7e92443cbc4c9bc9cda390d8d")
  }

  var body: some Scene {
    WindowGroup {
//      ContentView()
      Home(override: true)
        .environment(\.managedObjectContext, CloudPersistenceController.shared.container.viewContext)
    }
  }
}
