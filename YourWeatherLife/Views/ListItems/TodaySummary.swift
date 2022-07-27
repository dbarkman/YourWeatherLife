//
//  TodaySummary.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/11/22.
//

import SwiftUI
import OSLog

struct TodaySummary: View {

  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "EventListToday")

  @StateObject private var summary = SummaryViewModel.shared

  private let todayViewFontSize = Font.callout
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text("Today")
          .font(.title2)
        Image(systemName: "chevron.right")
          .symbolRenderingMode(.monochrome)
          .foregroundColor(Color("AccentColor"))
          .padding(.horizontal, 5)
      }
      .padding(.bottom, 1)
      if summary.todaySummary.precipitation {
        HStack {
          Text("\(summary.todaySummary.precipitationType):")
            .font(todayViewFontSize)
            .fontWeight(.semibold)
          Text("\(summary.todaySummary.precipitationPercent) chance")
            .font(todayViewFontSize)
        } //end of HStack
        .padding(.bottom, 1)
      }
      HStack {
        Text("Coldest:")
          .font(todayViewFontSize)
          .fontWeight(.semibold)
        Text(summary.todaySummary.coldestTemp)
          .font(todayViewFontSize)
        Text("at")
          .font(todayViewFontSize)
        Text(summary.todaySummary.coldestTime)
          .font(todayViewFontSize)
      } //end of HStack
      .padding(.bottom, 1)
      HStack {
        Text("Sunrise:")
          .font(todayViewFontSize)
          .fontWeight(.semibold)
        Text(summary.todaySummary.sunriseTemp)
          .font(todayViewFontSize)
        Text("at")
          .font(todayViewFontSize)
        Text(summary.todaySummary.sunriseTime)
          .font(todayViewFontSize)
      } //end of HStack
      .padding(.bottom, 1)
      HStack {
        Text("Warmest:")
          .font(todayViewFontSize)
          .fontWeight(.semibold)
        Text(summary.todaySummary.warmestTemp)
          .font(todayViewFontSize)
        Text("at")
          .font(todayViewFontSize)
        Text(summary.todaySummary.warmestTime)
          .font(todayViewFontSize)
      } //end of HStack
      .padding(.bottom, 1)
      HStack {
        Text("Sunset:")
          .font(todayViewFontSize)
          .fontWeight(.semibold)
        Text(summary.todaySummary.sunsetTemp)
          .font(todayViewFontSize)
        Text("at")
          .font(todayViewFontSize)
        Text(summary.todaySummary.sunsetTime)
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
      summary.fetchTodaySummary()
    }
  }
}

//struct EventListToday_Previews: PreviewProvider {
//  static var previews: some View {
//    EventListToday(precipitation: true, precipitationType: "Rain", precipitationPercent: "80%", coldestTemp: "68°", coldestTime: "4a", warmestTemp: "83°", warmestTime: "3p", sunriseTemp: "72°", sunriseTime: "7:14a", sunsetTemp: "76°", sunsetTime: "8:13p")
//  }
//}
