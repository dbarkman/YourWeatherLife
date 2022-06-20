//
//  EventListWeekend.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/11/22.
//

import SwiftUI

struct EventListWeekend: View {
  
  @State public var saturdayHighTemp: String
  @State public var saturdayLowTemp: String
  @State public var saturdaySummary: String
  @State public var sundayHighTemp: String
  @State public var sundayLowTemp: String
  @State public var sundaySummary: String
  
  private let todayViewFontSize = Font.callout
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text("This Weekend")
          .font(.title2)
      }
      .padding(.bottom, 1)
      HStack {
        Text("Saturday:")
          .font(todayViewFontSize)
          .fontWeight(.semibold)
        Text(saturdayHighTemp)
          .font(todayViewFontSize)
        Text("/")
          .font(todayViewFontSize)
        Text(saturdayLowTemp)
          .font(todayViewFontSize)
      } //end of HStack
      .padding(.bottom, 1)
      HStack {
        Text(saturdaySummary)
          .font(todayViewFontSize)
          .minimumScaleFactor(0.1)
      } //end of HStack
      .padding(.bottom, 1)
      HStack {
        Text("Sunday:")
          .font(todayViewFontSize)
          .fontWeight(.semibold)
        Text(sundayHighTemp)
          .font(todayViewFontSize)
        Text("/")
          .font(todayViewFontSize)
        Text(sundayLowTemp)
          .font(todayViewFontSize)
      } //end of HStack
      .padding(.bottom, 1)
      HStack {
        Text(sundaySummary)
          .font(todayViewFontSize)
          .minimumScaleFactor(0.1)
      } //end of HStack
      .padding(.bottom, 1)
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

struct EventListWeekend_Previews: PreviewProvider {
  static var previews: some View {
    EventListWeekend(saturdayHighTemp: "88°", saturdayLowTemp: "65°", saturdaySummary: "Sunny all day", sundayHighTemp: "91°", sundayLowTemp: "68°", sundaySummary: "Sunny morning, cloudy afternoon")
  }
}
