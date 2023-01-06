//
//  AppCrashing.swift
//  YourWeatherLife
//
//  Created by David Barkman on 1/4/23.
//

import SwiftUI
import Mixpanel

struct AppCrashing: View {
    var body: some View {
      ScrollView {
        VStack(alignment: .leading) {
          Text("Sorry About the Crashes")
            .font(.title)
          Text("If you experienced crashing with the January 3rd, 2023 release of the app, your database likely has some corrupt data.")
            .padding(.top, 5)
          Text("This was likely caused by me having to change weather data providers or just by the developer going so long between updates. 😬")
            .padding(.top, 5)
          Text("The best corse of action at this point, is to remove the app from your device, then reinstall the app from TestFlight.")
            .padding(.top, 5)
          Text("Any daily events you created should be backed up in iCloud and should reappear when you reinstall the app. This should be a one-time event, updating through TestFlight should be fine for future versions.")
            .padding(.top, 5)
          Text("Once you perform a clean \"Install\" from TestFlight, this screen will no longer appear and crashing caused by databases should cease.")
            .padding(.top, 5)
          Text("This app is in active development and may crash for other reasons, lol. 😆")
            .padding(.top, 5)
          Text("I will try to be more careful in the future, thank you so much for taking the time to test and use this app!")
            .padding(.top, 5)
          Text("-David Barkman, david.barkman13@gmail.com")
            .padding(.top, 5)
          Spacer()
        }
        .padding()
        .onAppear() {
          Mixpanel.mainInstance().track(event: "AppCrashing View")
        }
      }
    }
}

struct AppCrashing_Previews: PreviewProvider {
    static var previews: some View {
      AppCrashing()
    }
}
