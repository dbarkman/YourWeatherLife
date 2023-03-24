//
//  HourlyForecast.swift
//  YourWeatherLife
//
//  Created by David Barkman on 7/6/22.
//

import SwiftUI
import Mixpanel

struct HourlyForecast: View {
  
  @StateObject private var globalViewModel = GlobalViewModel.shared
  @StateObject private var forecastViewModel = ForecastViewModel.shared

  @State private var showFeedback = false

  var body: some View {
    NavigationStack {
      ZStack {
        BackgroundColor()
        List(forecastViewModel.forecastHours, id: \.self) { hour in
          ZStack {
            NavigationLink(destination: HourDetail(hour: hour, navigationTitle: hour.shortDisplayDate)) { }
              .opacity(0)
            ForecastListItem(displayDate: hour.displayDate, warmestTemp: hour.temperature, coldestTemp: hour.feelsLike, condition: hour.condition, conditionIcon: hour.conditionIcon, isHour: true)
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
        .navigationTitle("300+ Hour Forecast")
      }
      .onAppear() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(Color("NavigationBackground"))
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(Color("AccentColor"))
        Mixpanel.mainInstance().track(event: "336HourForecast View")
        Review.hourForecastViewed()
        globalViewModel.returningFromChildView = true
        forecastViewModel.create336HourForecast()
    }
    }
  }
}

//struct HourForecast_Previews: PreviewProvider {
//    static var previews: some View {
//        HourForecast()
//    }
//}
