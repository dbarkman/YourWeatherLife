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
        .toolbar(.visible, for: .tabBar)
        .toolbarBackground(Color("NavigationBackground"), for: .tabBar)
      DayForecast()
        .tabItem {
          Label("Daily", systemImage: "calendar")
        }
        .tag(1)
        .toolbar(.visible, for: .tabBar)
        .toolbarBackground(Color("NavigationBackground"), for: .tabBar)
      Home()
        .tabItem {
          Label("Events", systemImage: "calendar.badge.clock")
        }
        .tag(2)
        .toolbar(.visible, for: .tabBar)
        .toolbarBackground(Color("NavigationBackground"), for: .tabBar)
      DayDetail(dates: [globalViewModel.today], parent: "Home", isToday: true, navigationTitle: "Today")
        .tabItem {
          Label("Today", systemImage: "sun.and.horizon")
        }
        .tag(3)
        .toolbar(.visible, for: .tabBar)
        .toolbarBackground(Color("NavigationBackground"), for: .tabBar)
      DayDetail(dates: globalViewModel.weekend, parent: "Home", navigationTitle: "This Weekend")
        .tabItem {
          Label("Weekend", systemImage: "beach.umbrella")
        }
        .tag(4)
        .toolbar(.visible, for: .tabBar)
        .toolbarBackground(Color("NavigationBackground"), for: .tabBar)
    }
    .toolbarColorScheme(.dark, for: .tabBar)
  }
}

struct Tabs_Previews: PreviewProvider {
  static var previews: some View {
    Tabs()
  }
}
