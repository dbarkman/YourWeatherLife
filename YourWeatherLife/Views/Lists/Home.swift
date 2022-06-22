//
//  Home.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/10/22.
//

import SwiftUI
import Mixpanel
import OSLog

struct Home: View {

  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "Home")
  
  @StateObject private var globalViewModel = GlobalViewModel()
  @StateObject private var currentConditions = CurrentConditionsViewModel()
  
  let twoColumns = [
    GridItem(.fixed(100), spacing: 15), //horizontal spacing
    GridItem(.flexible())
  ]
  
  var body: some View {
    
    UITableView.appearance().backgroundColor = .clear
    
    return NavigationView {
      ZStack {
        BackgroundColor()
        VStack {
          LazyVGrid(columns: twoColumns, spacing: 20) { //vertical spacing
            ZStack {
              VStack {
                Text(currentConditions.ccDecoder?.current.displayTemp ?? "--")
                  .font(.largeTitle)
                  .minimumScaleFactor(0.1)
                  .padding(-7)
                HStack {
                  Text(currentConditions.ccDecoder?.current.condition.text ?? "unknown")
                    .font(.footnote)
                  .minimumScaleFactor(0.1)
                  AsyncImage(url: URL(string: "https:\(currentConditions.ccDecoder?.current.condition.icon ?? "")")) { image in
                    image
                      .resizable()
                      .frame(width: 50, height: 50)
                      .padding(-5)
                  } placeholder: {}
                } //end of HStack
              } //end of VStack
//              RoundedRectangle(cornerRadius: 10)
//                .stroke(.gray, lineWidth: 2)
//                .frame(width: 100, height: 100)
            } //end of ZStack
            .task {
              await currentConditions.fetchCurrentWeather()
            }
            ZStack {
              VStack(alignment: .trailing) {
                Text("Your Weather")
                  .font(.largeTitle)
                  .lineLimit(1)
                  .minimumScaleFactor(0.1)
                HStack {
                  Image(systemName: "location.fill")
                    .symbolRenderingMode(.monochrome)
                    .foregroundColor(Color.accentColor)
                  Text(currentConditions.ccDecoder?.location.name ?? "")
                    .font(.title2)
                    .minimumScaleFactor(0.1)
                  Text(currentConditions.ccDecoder?.location.region ?? "")
                    .font(.title2)
                    .minimumScaleFactor(0.1)
                  Image(systemName: "chevron.down")
                    .symbolRenderingMode(.monochrome)
                    .foregroundColor(Color.accentColor)
                } //end of HStack
              } //end of VStack
              RoundedRectangle(cornerRadius: 10)
                .stroke(.clear, lineWidth: 2)
                .frame(height: 100)
            } //end of ZStack
          } //end of LazyVGrid
          .padding(.horizontal)
          .padding(.bottom, 10)
          
          List {
            ZStack(alignment: .leading) {
              NavigationLink(destination: EventDetail(event: "Morning Commute")) { }
                .opacity(0)
              EventListItem(event: "Morning Commute:", times: "7a - 9a", summary: "75° Clear and dry")
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            ZStack(alignment: .leading) {
              NavigationLink(destination: EventDetail(event: "Lunch")) { }
                .opacity(0)
              EventListItem(event: "Lunch:", times: "11a - 12p", summary: "85° Cloudy and 20% chance of rain")
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            ZStack(alignment: .leading) {
              NavigationLink(destination: EventDetail(event: "Afternoon Commute")) { }
                .opacity(0)
              EventListItem(event: "Afternoon Commute:", times: "4p - 6p", summary: "82° Cloudy and 80% chance of rain")
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            ZStack(alignment: .leading) {
              NavigationLink(destination: DayDetail()) { }
                .opacity(0)
              EventListToday(precipitation: true, precipitationType: "Rain", precipitationTime: "4p", precipitationPercent: "80%", coldestTemp: "68°", coldestTime: "4a", warmestTemp: "83°", warmestTime: "3p", sunriseTemp: "72°", sunriseTime: "7:14a", sunsetTemp: "76°", sunsetTime: "8:13p")
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            ZStack(alignment: .leading) {
              NavigationLink(destination: WeekendDetail()) { }
                .opacity(0)
              EventListWeekend(saturdayHighTemp: "88°", saturdayLowTemp: "75°", saturdaySummary: "Sunny all day", sundayHighTemp: "91°", sundayLowTemp: "79°", sundaySummary: "Sunny morning, cloudy afternoon")
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            ZStack(alignment: .leading) {
              NavigationLink(destination: EventDetail(event: "Taco Tuesday")) { }
                .opacity(0)
              EventListCalendarItem(title: "Taco Tuesday Happy Hour on June 21", startTemp: "83°", startTime: "6p", endTemp: "75°", endTime: "9p", aroundSunrise: false, sunriseTemp: "", sunriseTime: "", aroundSunset: true, sunsetTemp: "76°", sunsetTime: "8:15p", precipitation: false, precipitationType: "", precipitationTime: "", precipitationPercent: "", eventWeatherSummary: "Cool and clear with no chance for rain")
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            ZStack(alignment: .leading) {
              NavigationLink(destination: EventDetail(event: "Group Hike")) { }
                .opacity(0)
              EventListCalendarItem(title: "Group hike on June 25", startTemp: "65°", startTime: "6:30a", endTemp: "72°", endTime: "9a", aroundSunrise: true, sunriseTemp: "67°", sunriseTime: "7:10a", aroundSunset: false, sunsetTemp: "", sunsetTime: "", precipitation: true, precipitationType: "rain", precipitationTime: "8a", precipitationPercent: "65%", eventWeatherSummary: "Cold and cloudy with a good chance of rain")
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
          } //end of List
          .listStyle(.plain)
          .refreshable {
            await currentConditions.fetchCurrentWeather()
          }
        }
        .navigationBarHidden(true)
        
        NavigationLink(destination: DailyEvents(), isActive: $globalViewModel.isShowingDailyEvents) { }
      } //end of VStack
      .onAppear() {
        Mixpanel.mainInstance().track(event: "Home View")
      }
    } //end of NavigationView
    .environmentObject(globalViewModel)
  }
}

struct ListView_Previews: PreviewProvider {
  static var previews: some View {
    Home()
  }
}
