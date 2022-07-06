//
//  DayDetail.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/12/22.
//

import SwiftUI
import Mixpanel

struct DayDetail: View {
  
  @StateObject private var dayDetail = DayDetailViewModel()
  @State var dates = [Dates.makeStringFromDate(date: Date(), format: "yyyy-MM-dd")]
  
  var body: some View {
    ZStack {
      BackgroundColor()
      List (dayDetail.todayArray, id: \.self) { day in
        Section (header: Text(day.dayOfWeek)) {
          Text("Coldest: \(day.coldestTemp) at \(day.coldestTime)")
          Text("Sunrise: \(day.sunriseTemp) at \(day.sunriseTime)")
          Text("Warmest: \(day.warmestTemp) at \(day.warmestTime)")
          Text("Sunset: \(day.sunsetTemp) at \(day.dayOfWeek)")
          if day.precipitation {
            Text("\(day.precipitationType): \(day.precipitationPercent) chance")
          }
        }
        .listRowBackground(Color("ListBackground"))
        Section(header: Text("Details")) {
          if let dayHours = day.hours {
            ForEach(dayHours, id: \.self) { hour in
              NavigationLink(destination: HourDetail(hour: hour).navigationTitle("\(day.dayOfWeek) @ \(hour.timeFull)")) {
                HStack {
                  Text("\(hour.time)")
                  AsyncImage(url: URL(string: "https:\(hour.conditionIcon)")) { image in
                    image.resizable()
                  } placeholder: {
                    Image("day/113")
                  }
                  .frame(width: 45, height: 45)
                  Text("\(hour.temperature) \(hour.condition)")
                }
              }
            }
          }
        } //end of Section
        .listRowBackground(Color("ListBackground"))
      } //end of List
      .listStyle(.plain)
    } //end of ZStack
    .onAppear() {
      let appearance = UINavigationBarAppearance()
      appearance.backgroundColor = UIColor(Color("NavigationBackground"))//.opacity(0.9))
      UINavigationBar.appearance().standardAppearance = appearance
      UINavigationBar.appearance().scrollEdgeAppearance = appearance
      Mixpanel.mainInstance().track(event: "DayDetail View")
      dayDetail.fetchDayDetail(dates: dates)
    }
  }
}


struct DayDetail_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      DayDetail()
    }
  }
}
