//
//  YourWeatherLifeApp.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/19/22.
//

import SwiftUI

@main
struct YourWeatherLifeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
