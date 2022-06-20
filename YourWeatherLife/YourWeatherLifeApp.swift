//
//  YourWeatherLifeApp.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/19/22.
//

import SwiftUI

@main
struct YourWeatherLifeApp: App {

  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  var body: some Scene {
    WindowGroup {
      Home()
//        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
  }
}
