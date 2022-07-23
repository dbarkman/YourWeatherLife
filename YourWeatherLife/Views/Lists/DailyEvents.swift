//
//  DailyEvents.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/10/22.
//

import SwiftUI
import CoreData
import Mixpanel
import OSLog

struct DailyEvents: View {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "DailyEvents")
  
  private var viewContext = LocalPersistenceController.shared.container.viewContext
  private var viewCloudContext = CloudPersistenceController.shared.container.viewContext
  
  @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \DailyEvent.startTime, ascending: true)], predicate: NSPredicate(value: true), animation: .default)
  private var events: FetchedResults<DailyEvent>

  @StateObject private var globalViewModel = GlobalViewModel.shared
  @StateObject private var eventViewModel = EventViewModel.shared
  
  @State private var showFeedback = false
  @State private var showAddEvent = false
  
  var body: some View {
    ZStack {
      BackgroundColor()
      List {
        Section(header: Text("Repeating Weekday Events")) {
          ForEach(events, id: \.self) { individualEvent in
            if let event = individualEvent.event, let start = individualEvent.startTime, let end = individualEvent.endTime {
              let days = individualEvent.days ?? "1234567"
              let daysIntArray = days.compactMap { $0.wholeNumberValue }
              NavigationLink(destination: EditDailyEvent(eventName: event, startTimeDate: Dates.shared.makeDateFromString(date: start, format: "HH:mm"), endTimeDate: Dates.shared.makeDateFromString(date: end, format: "HH:mm"), daysSelected: daysIntArray, oldEventName: event)) {
                HStack {
                  Text(event)
                  Spacer()
                  HStack {
                    Text(Dates.shared.makeDisplayTimeFromTime(time: start, format: "HH:mm"))
                    Text("-")
                    Text(Dates.shared.makeDisplayTimeFromTime(time: end, format: "HH:mm"))
                  }
                }
              }
            }
          } //end of ForEach
          .onDelete(perform: delete)
        } //end of Section
        .listRowBackground(Color("ListBackground"))
      } //end of list
      .navigationTitle("Events")
      .listStyle(.plain)
    } //end of ZStack
    .onAppear() {
      let appearance = UINavigationBarAppearance()
      appearance.backgroundColor = UIColor(Color("NavigationBackground"))//.opacity(0.9))
      UINavigationBar.appearance().standardAppearance = appearance
      UINavigationBar.appearance().scrollEdgeAppearance = appearance
      UINavigationBar.appearance().tintColor = UIColor(Color("AccentColor"))
      globalViewModel.returningFromChildView = true
        Mixpanel.mainInstance().track(event: "DailyEvents View")
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: add) {
          Label("Add Event", systemImage: "plus")
        }
      }
      ToolbarItem(placement: .navigationBarTrailing) {
        EditButton()
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
    .sheet(isPresented: $showAddEvent) {
      NavigationView {
        EditDailyEvent(addEvent: true, daysSelected: [1,2,3,4,5,6,7])
      }
    }
  }

  private func add() {
    showAddEvent = true
  }
  
  private func delete(offsets: IndexSet) {
    offsets.map { events[$0] }.forEach(viewCloudContext.delete)
    do {
      try viewCloudContext.save()
    } catch {
      logger.error("Could not delete Daily Event")
    }
  }
}

struct DailyEvents_Previews: PreviewProvider {
  static var previews: some View {
    DailyEvents()
  }
}
