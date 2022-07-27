//
//  DayForecast.swift
//  YourWeatherLife
//
//  Created by David Barkman on 7/6/22.
//

import SwiftUI
import Mixpanel
import OSLog

struct DayForecast: View {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "DayForecast")
  
  @StateObject private var globalViewModel = GlobalViewModel.shared
  @StateObject private var homeViewModel = HomeViewModel.shared
  
  @State private var showFeedback = false
  
  var body: some View {
    ZStack {
      BackgroundColor()
      List(homeViewModel.forecastDays, id: \.self) { day in
        ZStack {
          NavigationLink(destination: DayDetail(dates: [day.date], parent: "DayForecast", navigationTitle: "\(day.displayDate)")) { }
            .opacity(0)
          ForecastListItem(displayDate: day.displayDate, warmestTemp: day.warmestTemp, coldestTemp: day.coldestTemp, condition: day.condition, conditionIcon: day.conditionIcon)
        } //end of ZStack
        .listRowSeparator(.hidden)
        .listRowBackground(Color("ListBackground"))
      } //end of List
      .listStyle(.plain)
      .toolbar {
        ToolbarItem {
          Button(action: {
            showFeedback.toggle()
          }) {
            Label("Feedback", systemImage: "star")
          }
          .sheet(isPresented: $showFeedback) {
            FeedbackModal()
          }
        }
      }
      .navigationTitle("14 Day Forecast")
    }
    .onAppear() {
      let appearance = UINavigationBarAppearance()
      appearance.backgroundColor = UIColor(Color("NavigationBackground"))
      UINavigationBar.appearance().standardAppearance = appearance
      UINavigationBar.appearance().scrollEdgeAppearance = appearance
      UINavigationBar.appearance().tintColor = UIColor(Color("AccentColor"))
      Mixpanel.mainInstance().track(event: "14DayForecast View")
      globalViewModel.returningFromChildView = true
      homeViewModel.create14DayForecast()
    }
  }
}

struct DayForecast_Previews: PreviewProvider {
  static var previews: some View {
    DayForecast()
  }
}
