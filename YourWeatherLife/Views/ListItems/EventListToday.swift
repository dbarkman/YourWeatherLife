//
//  EventListToday.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/11/22.
//

import SwiftUI

struct EventListToday: View {
  
  @State var precipitation: Bool
  @State var precipitationType: String
  @State var precipitationTime: String
  @State var precipitationPercent: String
  @State var coldestTemp: String
  @State var coldestTime: String
  @State var warmestTemp: String
  @State var warmestTime: String
  @State var sunriseTemp: String
  @State var sunriseTime: String
  @State var sunsetTemp: String
  @State var sunsetTime: String
  
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
