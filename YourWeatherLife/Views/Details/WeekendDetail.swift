//
//  WeekendDetail.swift
//  YourDay
//
//  Created by David Barkman on 6/13/22.
//

import SwiftUI
import Mixpanel

struct WeekendDetail: View {
  var body: some View {
    ZStack {
      BackgroundColor()
      List {
        Section(header: Text("Saturday")) {
          Group {
            Text("Coldest: 75° at 4a°")
            Text("Sunrise: 77° at 7:14a")
            Text("Warmest: 88° at 3p")
            Text("Rain: 80% at 4p")
            Text("Sunset: 78° at 8:13p")
          }
          Group {
            NavigationLink(destination: HourDetail()) {
              Text("7a 🌗 75°")
            }
            Text("8a ☀️ 76°")
            Text("9a ☀️ 77°")
            Text("10a ☀️ 79°")
            Text("11a ☀️ 80°")
            Text("12p ☀️ 82°")
            Text("1p ☀️ 84°")
            Text("2p ☀️ 85°")
            Text("3p ☀️ 87°")
            Text("4p ☀️ 88°")
          }
          Group {
            Text("5p ☀️ 87°")
            NavigationLink(destination: HourDetail()) {
              Text("6p ☀️ 85°")
            }
            Text("7p ☀️ 82°")
            Text("8p ☀️ 78°")
            Text("9p 🌗 76°")
            Text("10p 🌗 75°")
            Text("11p 🌗 74°")
          }
        } //end of Section
        .listRowBackground(Color("ListBackground"))
        Section(header: Text("Sunday")) {
          Group {
            Text("Coldest: 79° at 4a°")
            Text("Sunrise: 82° at 7:14a")
            Text("Warmest: 91° at 3p")
            Text("Rain: 80% at 4p")
            Text("Sunset: 80° at 8:13p")
          }
          Group {
            NavigationLink(destination: HourDetail()) {
              Text("12a 🌗 82°")
            }
            Text("1a ☀️ 81°")
            Text("2a ☀️ 81°")
            Text("3a ☀️ 80°")
            Text("4a ☀️ 79°")
            Text("5a ☀️ 80°")
            Text("6a ☀️ 81°")
            NavigationLink(destination: HourDetail()) {
              Text("7a 🌗 82°")
            }
            Text("8a ☀️ 83°")
            Text("9a ☀️ 84°")
          }
          Group {
            Text("10a ☀️ 85°")
            Text("11a ☀️ 86°")
            Text("12p ☀️ 87°")
            Text("1p ☀️ 88°")
            Text("2p ☀️ 90°")
            Text("3p ☀️ 91°")
            Text("4p ☀️ 91°")
            Text("5p ☀️ 89°")
            NavigationLink(destination: HourDetail()) {
              Text("6p ☀️ 86°")
            }
            Text("7p ☀️ 83°")
          }
          Group {
            Text("8p ☀️ 80°")
            Text("9p 🌗 77°")
            Text("10p 🌗 75°")
            Text("11p 🌗 72°")
          }
        } //end of Section
        .listRowBackground(Color("ListBackground"))
      } //end of List
      .navigationTitle("Weekend")
      .listStyle(.plain)
    } //end of ZStack
    .onAppear() {
      let appearance = UINavigationBarAppearance()
      appearance.backgroundColor = UIColor(Color("NavigationBackground"))//.opacity(0.9))
      UINavigationBar.appearance().standardAppearance = appearance
      UINavigationBar.appearance().scrollEdgeAppearance = appearance
      Mixpanel.mainInstance().track(event: "WeekendDetail View")
    }
  }
}

struct WeekendDetail_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      WeekendDetail()
    }
  }
}
