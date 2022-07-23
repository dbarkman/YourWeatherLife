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
  @StateObject private var homeViewModel = HomeViewModel.shared

  @State private var showFeedback = false

  var body: some View {
    ZStack {
      BackgroundColor()
      List(homeViewModel.forecastHours, id: \.self) { hour in
        NavigationLink(destination: HourDetail(hour: hour).navigationTitle("\(hour.displayDate)")) {
          HStack {
            Text("\(hour.displayDate)")
            AsyncImage(url: URL(string: "https:\(hour.conditionIcon)")) { image in
              image.resizable()
            } placeholder: {
              Image("day/113")
            }
            .frame(width: 45, height: 45)
            Text("\(hour.temperature) \(hour.condition)")
          }
        }
        .listRowBackground(Color("ListBackground"))
      } //end of List
      .listStyle(.plain)
      .onAppear() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(Color("NavigationBackground"))//.opacity(0.9))
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(Color("AccentColor"))
        Mixpanel.mainInstance().track(event: "336HourForecast View")
        globalViewModel.returningFromChildView = true
        homeViewModel.create336HourForecast()
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
      .navigationTitle("336 Hour Forecast")
    }
  }
}

//struct HourForecast_Previews: PreviewProvider {
//    static var previews: some View {
//        HourForecast()
//    }
//}
