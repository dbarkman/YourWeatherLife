//
//  EventDetail.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/11/22.
//

import SwiftUI
import Mixpanel
import OSLog
import FirebaseAnalytics

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
      .overlay(event.forecastHours.isEmpty ? Text("No Data Available") : nil, alignment: .center)
      .navigationTitle(event.eventName)
      .listStyle(.plain)
    } //end of ZStack
    .toolbar {
      if dailyEvent {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Edit", action: {
            showEditEvent = true
          })
        }
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
      NavigationStack {
        let daysIntArray = event.days.compactMap { $0.wholeNumberValue }
        EditDailyEvent(eventName: event.eventName, startTimeDate: Dates.shared.makeDateFromString(date: event.startTime, format: "h:mma"), endTimeDate: Dates.shared.makeDateFromString(date: event.endTime, format: "h:mma"), daysSelected: daysIntArray, oldEventName: event.eventName, returningFromModal: $returningFromModal)
      }
      .accentColor(Color("AccentColor"))
    }
    .onAppear() {
      UINavigationBar.appearance().tintColor = UIColor(Color("AccentColor"))
      globalViewModel.returningFromChildView = true
      Mixpanel.mainInstance().track(event: "EventDetail View")
      Analytics.logEvent("View", parameters: ["view_name": "EventDetail"])
      Review.eventDetailViewed()
      
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
//    NavigationStack {
//      EventDetail(event: Event, forecastHours: [])
//    }
//  .accentColor(Color("AccentColor"))
//  }
//}
