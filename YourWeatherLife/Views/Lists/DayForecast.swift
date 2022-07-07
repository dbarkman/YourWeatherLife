//
//  DayForecast.swift
//  YourWeatherLife
//
//  Created by David Barkman on 7/6/22.
//

import SwiftUI
import Mixpanel

struct DayForecast: View {
  
  @StateObject private var homeViewModel = HomeViewModel()
  
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
            //            .frame(width: 5)
            AsyncImage(url: URL(string: "https:\(day.conditionIcon)")) { image in
              image.resizable()
            } placeholder: {
              Image("day/113")
            }
            .frame(width: 45, height: 45)
            Text("\(day.condition)")
              .minimumScaleFactor(0.1)
            //            .lineLimit(1)
            Spacer()
            //            .frame(width: 5)
            Text(" \(day.warmestTemp)/\(day.coldestTemp)")
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
        Mixpanel.mainInstance().track(event: "14DayForecast View")
        homeViewModel.create14DayForecast()
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
