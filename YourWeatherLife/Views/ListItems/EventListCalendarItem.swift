//
//  EventListCalendarItem.swift
//  YourDay
//
//  Created by David Barkman on 6/11/22.
//

import SwiftUI

struct EventListCalendarItem: View {
  
  @State public var title: String
  @State public var startTemp: String
  @State public var startTime: String
  @State public var endTemp: String
  @State public var endTime: String
  @State public var aroundSunrise: Bool
  @State public var sunriseTemp: String
  @State public var sunriseTime: String
  @State public var aroundSunset: Bool
  @State public var sunsetTemp: String
  @State public var sunsetTime: String
  @State public var precipitation: Bool
  @State public var precipitationType: String
  @State public var precipitationTime: String
  @State public var precipitationPercent: String
  @State public var eventWeatherSummary: String
  
  private let todayViewFontSize = Font.callout
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text(title)
          .font(.title2)
          .minimumScaleFactor(0.1)
      }
      .padding(.bottom, 1)
      HStack {
        Text("Start:")
          .font(todayViewFontSize)
          .fontWeight(.semibold)
        Text(startTemp)
          .font(todayViewFontSize)
        Text("at")
          .font(todayViewFontSize)
        Text(startTime)
          .font(todayViewFontSize)
      } //end of HStack
      .padding(.bottom, 1)
      if aroundSunrise {
        HStack {
          Text("Sunrise:")
            .font(todayViewFontSize)
            .fontWeight(.semibold)
          Text(sunriseTemp)
            .font(todayViewFontSize)
          Text("at")
            .font(todayViewFontSize)
          Text(sunriseTime)
            .font(todayViewFontSize)
        } //end of HStack
        .padding(.bottom, 1)
      }
      HStack {
        Text("End:")
          .font(todayViewFontSize)
          .fontWeight(.semibold)
        Text(endTemp)
          .font(todayViewFontSize)
        Text("at")
          .font(todayViewFontSize)
        Text(endTime)
          .font(todayViewFontSize)
      } //end of HStack
      .padding(.bottom, 1)
      if aroundSunset {
        HStack {
          Text("Sunset:")
            .font(todayViewFontSize)
            .fontWeight(.semibold)
          Text(sunsetTemp)
            .font(todayViewFontSize)
          Text("at")
            .font(todayViewFontSize)
          Text(sunsetTime)
            .font(todayViewFontSize)
        } //end of HStack
        .padding(.bottom, 1)
      }
      if precipitation {
        HStack {
          Text("\(precipitationType):")
            .font(todayViewFontSize)
            .fontWeight(.semibold)
          Text("\(precipitationPercent)")
            .font(todayViewFontSize)
          Text("at")
            .font(todayViewFontSize)
          Text(precipitationTime)
            .font(todayViewFontSize)
        } //end of HStack
        .padding(.bottom, 1)
      } //end of HStack
      HStack {
        Text(eventWeatherSummary)
          .font(todayViewFontSize)
          .minimumScaleFactor(0.1)
      } //end of HStack
    } //end of VStack
    .padding([.leading, .trailing, .top], 10)
    .padding(.bottom, 20)
    .overlay {
      RoundedRectangle(cornerRadius: 10)
        .stroke(.gray, lineWidth: 2)
        .padding(.bottom, 10)
    }
  }
}

struct EventListCalendarItem_Previews: PreviewProvider {
  static var previews: some View {
    EventListCalendarItem(title: "Taco Tuesday Happy Hour on June 14", startTemp: "83°", startTime: "6p", endTemp: "75°", endTime: "9p", aroundSunrise: false, sunriseTemp: "", sunriseTime: "", aroundSunset: true, sunsetTemp: "76°", sunsetTime: "8:15p", precipitation: false, precipitationType: "", precipitationTime: "", precipitationPercent: "", eventWeatherSummary: "Cool and clear with no chance for rain")
  }
}
