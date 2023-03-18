//
//  CalendarEvents.swift
//  YourWeatherLife
//
//  Created by David Barkman on 1/18/23.
//

import SwiftUI
import CoreData
import EventKit
import Mixpanel
import OSLog

struct CalendarEvents: View {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "CalendarEvents")
  
  @Environment(\.presentationMode) var presentationMode
  
  @StateObject private var eventStoreViewModel = EventStoreViewModel.shared
  @StateObject private var calendarEventViewModel = CalendarEventViewModel.shared
  @StateObject private var homeViewModel = HomeViewModel.shared

  @State private var showCalendars = false
  @State private var returningFromCalendars = false
  @State private var selectedEvents: [String] = []

  var body: some View {
    ZStack {
      BackgroundColor()
      
      List {
        Text("events occuring within the next 14 days")
          .font(.callout)
          .listRowBackground(Color("ListBackground"))
        ForEach(eventStoreViewModel.eventSets) { section in
          Section(header: Text(section.calendar)) {
            ForEach(section.events, id: \.self) { event in
              Button(
                action: {
                  if let index = selectedEvents.firstIndex(where: { $0 == event }) {
                    selectedEvents.remove(at: index)
                  } else {
                    selectedEvents.append(event)
                  }
                }) {
                  HStack {
                    Image(systemName: selectedEvents.contains(event) ? "checkmark.circle.fill" : "circle")
                      .foregroundColor(Color(cgColor: section.color))
                      .font(.system(size: 25))
                    Text(event)
                  }
                }
                .listRowBackground(Color("ListBackground"))
            }
          }
        }
      }
      .listStyle(.plain)
      .navigationTitle("Calendar Events")
      .navigationBarBackButtonHidden(true)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: {
            UserDefaults.standard.set(Array(selectedEvents), forKey: "selectedEvents")
            CalendarEventProvider.shared.insertCalendarEvents(selectedEvents: selectedEvents, eventIdsByName: eventStoreViewModel.eventIdsByName)
            _ = homeViewModel.fetchImportedEvents()
            presentationMode.wrappedValue.dismiss()
          }) {
            Text("Done")
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            showCalendars = true
          }) {
            Text("Calendars")
          }
        }
      }
      .sheet(isPresented: $showCalendars) {
        NavigationStack {
          Calendars()
        }
      }
    }
    .alert(Text("All Calendars Selected"), isPresented: $eventStoreViewModel.allCalendarsSelected, actions: {
      Button("OK") { }
    }, message: {
      Text("By default, all calendars are selected. Tap Calendars above to limit the selection.")
    })
    .onAppear() {
      let appearance = UINavigationBarAppearance()
      appearance.backgroundColor = UIColor(Color("NavigationBackground"))
      UINavigationBar.appearance().standardAppearance = appearance
      UINavigationBar.appearance().scrollEdgeAppearance = appearance
      UINavigationBar.appearance().tintColor = UIColor(Color("AccentColor"))
      Mixpanel.mainInstance().track(event: "CalendarEvents")
      let authStatus = EKEventStore.authorizationStatus(for: .event)
      if authStatus == .notDetermined {
        EventStoreViewModel.shared.requestAccess()
      } else if authStatus == .authorized {
        eventStoreViewModel.fetchEvents()
//        calendarEventViewModel.fetchCalendarEvents()
      }
      
      DispatchQueue.main.async {
        if let selectedEvents = UserDefaults.standard.object(forKey: "selectedEvents") as? [String] {
          self.selectedEvents = selectedEvents
        }
      }
    }
  }
}

//struct CalendarEvents_Previews: PreviewProvider {
//    static var previews: some View {
//        CalendarEvents()
//    }
//}
