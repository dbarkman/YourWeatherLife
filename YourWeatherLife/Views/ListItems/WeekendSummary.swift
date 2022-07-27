//
//  WeekendSummary.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/11/22.
//

import SwiftUI

struct WeekendSummary: View {
  
  @StateObject private var summary = SummaryViewModel.shared
  
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
        Text(summary.weekendSummary.saturdayHigh)
          .font(todayViewFontSize)
        Text("/")
          .font(todayViewFontSize)
        Text(summary.weekendSummary.saturdayLow)
          .font(todayViewFontSize)
      } //end of HStack
      .padding(.bottom, 1)
      HStack {
        Text(summary.weekendSummary.saturdayCondition)
          .font(todayViewFontSize)
          .minimumScaleFactor(0.1)
      } //end of HStack
      .padding(.bottom, 1)
      if summary.weekendSummary.saturdayPrecipitation {
        HStack {
          Text("\(summary.weekendSummary.saturdayPrecipitationType):")
            .font(todayViewFontSize)
            .fontWeight(.semibold)
          Text("\(summary.weekendSummary.saturdayPrecipitationPercent) chance")
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
        Text(summary.weekendSummary.sundayHigh)
          .font(todayViewFontSize)
        Text("/")
          .font(todayViewFontSize)
        Text(summary.weekendSummary.sundayLow)
          .font(todayViewFontSize)
      } //end of HStack
      .padding(.bottom, 1)
      HStack {
        Text(summary.weekendSummary.sundayCondition)
          .font(todayViewFontSize)
          .minimumScaleFactor(0.1)
      } //end of HStack
      .padding(.bottom, 1)
      if summary.weekendSummary.sundayPrecipitation {
        HStack {
          Text("\(summary.weekendSummary.sundayPrecipitationType):")
            .font(todayViewFontSize)
            .fontWeight(.semibold)
          Text("\(summary.weekendSummary.sundayPrecipitationPercent) chance")
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
      summary.fetchWeekendSummary()
    }
  }
}

struct EventListWeekend_Previews: PreviewProvider {
  static var previews: some View {
    WeekendSummary()
  }
}
