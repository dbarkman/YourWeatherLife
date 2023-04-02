//
//  Tabs.swift
//  YourWeatherLife
//
//  Created by David Barkman on 3/23/23.
//

import SwiftUI

struct Tabs: View {
  
  @StateObject private var globalViewModel = GlobalViewModel.shared

  var body: some View {
    TabView(selection: $globalViewModel.selectedTab) {
      HourlyForecast()
        .tabItem {
          Label("Hourly", systemImage: "clock")
        }
        .tag(0)
      DailyForecast()
        .tabItem {
          Label("Daily", systemImage: "calendar")
        }
        .tag(1)
      Home()
        .tabItem {
          Label("Events", systemImage: "calendar.badge.clock")
        }
        .tag(2)
      DayDetail(dates: [globalViewModel.today], parent: "Home", isToday: true, navigationTitle: "Today")
        .tabItem {
          Label("Today", systemImage: "sun.and.horizon")
        }
        .tag(3)
      DayDetail(dates: globalViewModel.weekend, parent: "Home", navigationTitle: "This Weekend")
        .tabItem {
          Label("Weekend", systemImage: "beach.umbrella")
        }
        .tag(4)
    }
  }
}

struct Tabs_Previews: PreviewProvider {
  static var previews: some View {
    Tabs()
  }
}
