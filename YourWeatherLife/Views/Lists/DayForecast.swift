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
  
  @StateObject private var homeViewModel = HomeViewModel()
  
  @State var showingFeedback = false

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
        Mixpanel.mainInstance().track(event: "14DayForecast View")
        homeViewModel.create14DayForecast()
      }
      .toolbar {
        ToolbarItem {
          Button(action: {
            showingFeedback.toggle()
          }) {
            Label("Feedback", systemImage: "star")
          }
          .sheet(isPresented: $showingFeedback) {
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
