//
//  DayDetail.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/12/22.
//

import SwiftUI
import Mixpanel
import OSLog

struct DayDetail: View {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "DayDetail")
  
  @StateObject private var globalViewModel = GlobalViewModel.shared
  @StateObject private var dayDetail = DayDetailViewModel.shared
  
  @State private var showFeedback = false
  @State var dates = [Dates.shared.makeStringFromDate(date: Date(), format: "yyyy-MM-dd")]
  
  var parent: String
  var isToday = false
  var navigationTitle: String
  
  var body: some View {
    ZStack {
      BackgroundColor()
      List (dayDetail.todayArray, id: \.self) { day in
        Section(header: Text("\(day.dayOfWeek)'s Temperatures")) {
          Group { //temps
            HStack {
              Text("Coldest:")
                .fontWeight(.semibold)
              Text("\(day.coldestTemp) at \(day.coldestTime)")
            }
            HStack {
              Text("Sunrise:")
                .fontWeight(.semibold)
              Text("\(day.sunriseTemp) at \(day.sunriseTime)")
            }
            HStack {
              Text("Warmest:")
                .fontWeight(.semibold)
              Text("\(day.warmestTemp) at \(day.warmestTime)")
            }
            HStack {
              Text("Sunset:")
                .fontWeight(.semibold)
              Text("\(day.sunsetTemp) at \(day.sunsetTime)")
            }
          }
        }
        .listRowBackground(Color("ListBackground"))
        Section(header: Text("\(day.dayOfWeek)'s Conditions")) {
          Group {
            HStack {
              Text("Conditions:")
                .fontWeight(.semibold)
              Text("\(day.condition)")
            }
            if day.precipitation {
              HStack {
                Text("\(day.precipitationType):")
                  .fontWeight(.semibold)
                Text("\(day.precipitationPercent) chance")
              }
            }
            HStack {
              Text("Winds:")
                .fontWeight(.semibold)
              Text("\(day.wind)")
            }
            HStack {
              Text("Humidity:")
                .fontWeight(.semibold)
              Text("\(day.humidity)%")
            }
            HStack {
              Text("Max UV:")
                .fontWeight(.semibold)
              Text("\(day.uv)")
            }
          }
        }
        .listRowBackground(Color("ListBackground"))
        Section(header: Text("\(day.dayOfWeek)'s Lunar Details")) {
          Group { //moon stuff
            HStack {
              Text("Moon Phase:")
                .fontWeight(.semibold)
              Text("\(day.moonPhase)")
            }
            HStack {
              Text("Moonrise:")
                .fontWeight(.semibold)
              Text("\(day.moonRiseTime)")
              Text("Moonset:")
                .fontWeight(.semibold)
              Text("\(day.moonSetTime)")
            }
          }
        }
        .listRowBackground(Color("ListBackground"))
        Section (header: Text(day.dayOfWeek)) {
          ForEach(day.hours, id: \.self) { hour in
            NavigationLink(destination: HourDetail(hour: hour, navigationTitle: parent == "Home" ? "\(day.dayOfWeek), \(hour.timeFull)" : "\(hour.shortDisplayDate)")) {
              HStack {
                VStack(alignment: .leading) {
                  Text("\(hour.time)")
                    .fontWeight(.semibold)
                  Text("\(hour.temperature) \(hour.condition)")
                }
                Spacer()
                AsyncImage(url: URL(string: "https:\(hour.conditionIcon)")) { image in
                  image.resizable()
                } placeholder: {
                  Image("day/113")
                }
                .frame(width: 64, height: 64)
              }
            }
          }
        } //end of Section
        .listRowBackground(Color("ListBackground"))
      } //end of List
      .listStyle(.plain)
      .navigationTitle(navigationTitle)
    } //end of ZStack
    .toolbar {
      ToolbarItem {
        Button(action: {
          showFeedback.toggle()
        }) {
          Label("Feedback", systemImage: "star")
        }
        .sheet(isPresented: $showFeedback) {
          FeedbackModal()
        }
      }
    }
    .onAppear() {
      let appearance = UINavigationBarAppearance()
      appearance.backgroundColor = UIColor(Color("NavigationBackground"))//.opacity(0.9))
      UINavigationBar.appearance().standardAppearance = appearance
      UINavigationBar.appearance().scrollEdgeAppearance = appearance
      UINavigationBar.appearance().tintColor = UIColor(Color("AccentColor"))
      Mixpanel.mainInstance().track(event: "DayDetail View")
      
      if parent == "Home" {
        globalViewModel.returningFromChildView = true
      }
      dayDetail.fetchDayDetail(dates: dates, isToday: isToday)
    }
  }
}


struct DayDetail_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      DayDetail(parent: "Self", navigationTitle: "Day")
    }
    .accentColor(Color("AccentColor"))
  }
}
