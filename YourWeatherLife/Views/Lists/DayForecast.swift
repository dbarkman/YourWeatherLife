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
        NavigationLink(destination: DayDetail(dates: [day.date]).navigationTitle("\(day.displayDate)")) {
          HStack {
            Text("\(day.displayDate)")
              .minimumScaleFactor(0.1)
              .lineLimit(1)
            Spacer()
            AsyncImage(url: URL(string: "https:\(day.conditionIcon)")) { image in
              image.resizable()
            } placeholder: {
              Image("day/113")
            }
            .frame(width: 45, height: 45)
            Text("\(day.condition)")
              .minimumScaleFactor(0.1)
            Spacer()
            Text(" \(day.warmestTemp)/\(day.coldestTemp)")
          }
        }
        .listRowBackground(Color("ListBackground"))
      } //end of List
      .listStyle(.plain)
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
  }
}

//struct DayForecast_Previews: PreviewProvider {
//    static var previews: some View {
//        DayForecast()
//    }
//}
