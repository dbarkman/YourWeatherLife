//
//  EventListToday.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/11/22.
//

import SwiftUI
import OSLog

struct EventListToday: View {

  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "EventListToday")

  @StateObject private var today = TodaySummaryViewModel()

  private let todayViewFontSize = Font.callout
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text("Today")
          .font(.title2)
        Image(systemName: "chevron.right")
          .symbolRenderingMode(.monochrome)
          .foregroundColor(Color.accentColor)
          .padding(.horizontal, 5)
      }
      .padding(.bottom, 1)
      if today.summary.precipitation {
        HStack {
          Text("\(today.summary.precipitationType):")
            .font(todayViewFontSize)
            .fontWeight(.semibold)
          Text("\(today.summary.precipitationPercent) chance")
            .font(todayViewFontSize)
        } //end of HStack
        .padding(.bottom, 1)
      }
      HStack {
        Text("Coldest:")
          .font(todayViewFontSize)
          .fontWeight(.semibold)
        Text(today.summary.coldestTemp)
          .font(todayViewFontSize)
        Text("at")
          .font(todayViewFontSize)
        Text(today.summary.coldestTime)
          .font(todayViewFontSize)
      } //end of HStack
      .padding(.bottom, 1)
      HStack {
        Text("Sunrise:")
          .font(todayViewFontSize)
          .fontWeight(.semibold)
        Text(today.summary.sunriseTemp)
          .font(todayViewFontSize)
        Text("at")
          .font(todayViewFontSize)
        Text(today.summary.sunriseTime)
          .font(todayViewFontSize)
      } //end of HStack
      .padding(.bottom, 1)
      HStack {
        Text("Warmest:")
          .font(todayViewFontSize)
          .fontWeight(.semibold)
        Text(today.summary.warmestTemp)
          .font(todayViewFontSize)
        Text("at")
          .font(todayViewFontSize)
        Text(today.summary.warmestTime)
          .font(todayViewFontSize)
      } //end of HStack
      .padding(.bottom, 1)
      HStack {
        Text("Sunset:")
          .font(todayViewFontSize)
          .fontWeight(.semibold)
        Text(today.summary.sunsetTemp)
          .font(todayViewFontSize)
        Text("at")
          .font(todayViewFontSize)
        Text(today.summary.sunsetTime)
          .font(todayViewFontSize)
      } //end of HStack
    } //end of VStack
    .padding([.leading, .trailing, .top], 10)
    .padding(.bottom, 20)
    .overlay {
      RoundedRectangle(cornerRadius: 10)
        .stroke(.gray, lineWidth: 2)
        .padding(.bottom, 10)
    }
    .task() {
      today.fetchTodaySummary()
    }
  }
}

//struct EventListToday_Previews: PreviewProvider {
//  static var previews: some View {
//    EventListToday(precipitation: true, precipitationType: "Rain", precipitationPercent: "80%", coldestTemp: "68°", coldestTime: "4a", warmestTemp: "83°", warmestTime: "3p", sunriseTemp: "72°", sunriseTime: "7:14a", sunsetTemp: "76°", sunsetTime: "8:13p")
//  }
//}
