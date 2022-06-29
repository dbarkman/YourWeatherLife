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
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "YourWeatherLifeApp")

  init() {
    Mixpanel.initialize(token: "f8ba28b7e92443cbc4c9bc9cda390d8d")
    
    if UserDefaults.standard.bool(forKey: "apisFetched") {
      Task {
        await DataService().fetchAPIsFromCloud()
        await TGW_ForecastProvider.shared.fetchForecast()
      }
    }
  }

  var body: some Scene {
    WindowGroup {
//      ContentView()
      Home()
        .environment(\.managedObjectContext, CloudPersistenceController.shared.container.viewContext)
    }
  }
}
