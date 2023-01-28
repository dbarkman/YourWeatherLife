//
//  EventDetail.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/11/22.
//

import SwiftUI
import Mixpanel
import OSLog

struct EventDetail: View {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "EventDetail")
  
  @StateObject private var globalViewModel = GlobalViewModel.shared
  @StateObject private var homeViewModel = HomeViewModel.shared

  @State private var showFeedback = false
  @State private var showEditEvent = false
  @State var event = EventForecast()
  @State var eventName = ""
  @State var returningFromModal = false
  
  var dailyEvent = true

//    if event == "Taco Tuesday" {
//      let hourDetails1 = HourDetails(id: UUID(), current: "83° and Sunny", winds: "Winds 2 mph from the southwest", precip: "15% humidity, no chance of rain")
//      let hour1 = Hour(id: UUID(), title: "6:00 PM ☀️", details: hourDetails1)
//      let hourDetails2 = HourDetails(id: UUID(), current: "80° and Partly Sunny", winds: "Winds 5 mph from the west", precip: "10% humidity, no chance of rain")
//      let hour2 = Hour(id: UUID(), title: "7:00 PM ☀️", details: hourDetails2)
//      let hourDetails3 = HourDetails(id: UUID(), current: "77° and Sunny", winds: "Winds 1 mph from the west", precip: "10% humidity, no chance of rain")
//      let hour3 = Hour(id: UUID(), title: "8:00 PM ☀️", details: hourDetails3)
//      let hourDetails4 = HourDetails(id: UUID(), current: "77° and Clear", winds: "Winds 1 mph from the west", precip: "5% humidity, no chance of rain")
//      let hour4 = Hour(id: UUID(), title: "9:00 PM 🌗", details: hourDetails4)
//      hours = [hour1, hour2, hour3, hour4]
//    } else if event == "Group Hike" {
//      let hourDetails1 = HourDetails(id: UUID(), current: "65° and Sunny", winds: "Winds 2 mph from the southwest", precip: "45% humidity, chance of rain")
//      let hour1 = Hour(id: UUID(), title: "6:00 AM ☁️", details: hourDetails1)
//      let hourDetails2 = HourDetails(id: UUID(), current: "67° and Partly Sunny", winds: "Winds 5 mph from the west", precip: "50% humidity, chance of rain")
//      let hour2 = Hour(id: UUID(), title: "7:00 AM ☁️", details: hourDetails2)
//      let hourDetails3 = HourDetails(id: UUID(), current: "70° and Sunny", winds: "Winds 1 mph from the west", precip: "70% humidity, good chance of rain")
//      let hour3 = Hour(id: UUID(), title: "8:00 AM 🌧", details: hourDetails3)
//      let hourDetails4 = HourDetails(id: UUID(), current: "72° and Clear", winds: "Winds 1 mph from the west", precip: "95% humidity, good chance of rain")
//      let hour4 = Hour(id: UUID(), title: "9:00 AM 🌧", details: hourDetails4)
//      hours = [hour1, hour2, hour3, hour4]
  
  var body: some View {
    ZStack {
      BackgroundColor()
      List(event.forecastHours, id: \.self) { hour in
        Section(header: Text(hour.timeFull)) {
          NavigationLink(destination: HourDetail(hour: hour, navigationTitle: hour.timeFull)) {
            Text("\(hour.temperature) and \(hour.condition)")
          }
          NavigationLink(destination: HourDetail(hour: hour, navigationTitle: hour.timeFull)) {
            Text("Winds \(hour.wind) from the \(hour.windDirection)")
          }
          NavigationLink(destination: HourDetail(hour: hour, navigationTitle: hour.timeFull)) {
            Text("\(hour.humidity)% humidity, \(hour.rainChance)% chance of rain")
          }
        }
        .listRowBackground(Color("ListBackground"))
      } // end of List
      .navigationTitle(event.eventName)
      .listStyle(.plain)
    } //end of ZStack
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button("Edit", action: {
          showEditEvent = true
        })
      }
      ToolbarItem(placement: .navigationBarTrailing) {
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
    .sheet(isPresented: $showEditEvent) {
      NavigationView {
        let daysIntArray = event.days.compactMap { $0.wholeNumberValue }
        EditDailyEvent(eventName: event.eventName, startTimeDate: Dates.shared.makeDateFromString(date: event.startTime, format: "h:mma"), endTimeDate: Dates.shared.makeDateFromString(date: event.endTime, format: "h:mma"), daysSelected: daysIntArray, oldEventName: event.eventName, returningFromModal: $returningFromModal)
      }
      .accentColor(Color("AccentColor"))
    }
    .onAppear() {
      let appearance = UINavigationBarAppearance()
      appearance.backgroundColor = UIColor(Color("NavigationBackground"))//.opacity(0.9))
      UINavigationBar.appearance().standardAppearance = appearance
      UINavigationBar.appearance().scrollEdgeAppearance = appearance
      UINavigationBar.appearance().tintColor = UIColor(Color("AccentColor"))
      globalViewModel.returningFromChildView = true
      Mixpanel.mainInstance().track(event: "EventDetail View")
      
      logger.debug("EventDetail onAppear")
      
      if dailyEvent {
        event = homeViewModel.createUpdateEventList(eventPredicate: eventName)
      } else {
        event = homeViewModel.fetchImportedEvents(eventPredicate: eventName)
      }
    }
    .onChange(of: returningFromModal) { _ in
      if returningFromModal {
        event = homeViewModel.createUpdateEventList(eventPredicate: eventName)
        returningFromModal = false
      }
    }
  }
}

//struct EventDetail_Previews: PreviewProvider {
//  static var previews: some View {
//    NavigationView {
//      EventDetail(event: Event, forecastHours: [])
//    }
//  .accentColor(Color("AccentColor"))
//  }
//}
