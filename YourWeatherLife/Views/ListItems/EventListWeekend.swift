//
//  EventListWeekend.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/11/22.
//

import SwiftUI

struct EventListWeekend: View {
  
  @StateObject private var weekend = WeekendSummaryViewModel.shared
  
  private let todayViewFontSize = Font.callout
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text("This Weekend")
          .font(.title2)
        Image(systemName: "chevron.right")
          .symbolRenderingMode(.monochrome)
          .foregroundColor(Color("AccentColor"))
          .padding(.horizontal, 5)
      }
      .padding(.bottom, 1)
      HStack {
        Text("Saturday:")
          .font(todayViewFontSize)
          .fontWeight(.semibold)
        Text(weekend.summary.saturdayHigh)
          .font(todayViewFontSize)
        Text("/")
          .font(todayViewFontSize)
        Text(weekend.summary.saturdayLow)
          .font(todayViewFontSize)
      } //end of HStack
      .padding(.bottom, 1)
      HStack {
        Text(weekend.summary.saturdayCondition)
          .font(todayViewFontSize)
          .minimumScaleFactor(0.1)
      } //end of HStack
      .padding(.bottom, 1)
      if weekend.summary.saturdayPrecipitation {
        HStack {
          Text("\(weekend.summary.saturdayPrecipitationType):")
            .font(todayViewFontSize)
            .fontWeight(.semibold)
          Text("\(weekend.summary.saturdayPrecipitationPercent) chance")
            .font(todayViewFontSize)
        } //end of HStack
        .padding(.bottom, 1)
      }
      Divider()
        .background(.black)
        .frame(width: 150)
      HStack {
        Text("Sunday:")
          .font(todayViewFontSize)
          .fontWeight(.semibold)
        Text(weekend.summary.sundayHigh)
          .font(todayViewFontSize)
        Text("/")
          .font(todayViewFontSize)
        Text(weekend.summary.sundayLow)
          .font(todayViewFontSize)
      } //end of HStack
      .padding(.bottom, 1)
      HStack {
        Text(weekend.summary.sundayCondition)
          .font(todayViewFontSize)
          .minimumScaleFactor(0.1)
      } //end of HStack
      .padding(.bottom, 1)
      if weekend.summary.sundayPrecipitation {
        HStack {
          Text("\(weekend.summary.sundayPrecipitationType):")
            .font(todayViewFontSize)
            .fontWeight(.semibold)
          Text("\(weekend.summary.sundayPrecipitationPercent) chance")
            .font(todayViewFontSize)
        } //end of HStack
        .padding(.bottom, 1)
      }
    } //end of VStack
    .padding([.leading, .trailing, .top], 10)
    .padding(.bottom, 20)
    .overlay {
      RoundedRectangle(cornerRadius: 10)
        .stroke(.gray, lineWidth: 2)
        .padding(.bottom, 10)
    }
    .task() {
      weekend.fetchWeekendSummary()
    }
  }
}

struct EventListWeekend_Previews: PreviewProvider {
  static var previews: some View {
    EventListWeekend()
  }
}
