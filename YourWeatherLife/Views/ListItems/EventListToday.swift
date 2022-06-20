//
//  EventListToday.swift
//  YourDay
//
//  Created by David Barkman on 6/11/22.
//

import SwiftUI

struct EventListToday: View {
  
  @State public var precipitation: Bool
  @State public var precipitationType: String
  @State public var precipitationTime: String
  @State public var precipitationPercent: String
  @State public var coldestTemp: String
  @State public var coldestTime: String
  @State public var warmestTemp: String
  @State public var warmestTime: String
  @State public var sunriseTemp: String
  @State public var sunriseTime: String
  @State public var sunsetTemp: String
  @State public var sunsetTime: String
  
  private let todayViewFontSize = Font.callout
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text("Today")
          .font(.title2)
      }
      .padding(.bottom, 1)
      HStack {
        Text("Coldest:")
          .font(todayViewFontSize)
          .fontWeight(.semibold)
        Text(coldestTemp)
          .font(todayViewFontSize)
        Text("at")
          .font(todayViewFontSize)
        Text(coldestTime)
          .font(todayViewFontSize)
      } //end of HStack
      .padding(.bottom, 1)
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
      HStack {
        Text("Warmest:")
          .font(todayViewFontSize)
          .fontWeight(.semibold)
        Text(warmestTemp)
          .font(todayViewFontSize)
        Text("at")
          .font(todayViewFontSize)
        Text(warmestTime)
          .font(todayViewFontSize)
      } //end of HStack
      .padding(.bottom, 1)
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
      }
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

struct EventListToday_Previews: PreviewProvider {
  static var previews: some View {
    EventListToday(precipitation: true, precipitationType: "Rain", precipitationTime: "4p", precipitationPercent: "80%", coldestTemp: "68°", coldestTime: "4a", warmestTemp: "83°", warmestTime: "3p", sunriseTemp: "72°", sunriseTime: "7:14a", sunsetTemp: "76°", sunsetTime: "8:13p")
  }
}
