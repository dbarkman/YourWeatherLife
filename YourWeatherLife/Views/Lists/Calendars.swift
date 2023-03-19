//
//  Calendars.swift
//  YourWeatherLife
//
//  Created by David Barkman on 1/18/23.
//

import SwiftUI
import Mixpanel
import EventKit

struct Calendars: View {
  
  @Environment(\.presentationMode) var presentationMode
  
  @StateObject private var eventStoreViewModel = EventStoreViewModel.shared
  
  @State private var selectedCalendars: [String] = []
  
  var body: some View {
    ZStack {
      BackgroundColor()
      
      List {
        ForEach(eventStoreViewModel.calendarSets) { section in
          Section(header: Text(section.title)) {
            ForEach(section.calendars, id: \.self) { calendar in
              Button(
                action: {
                  if let index = selectedCalendars.firstIndex(where: { $0 == calendar.calendarIdentifier }) {
                    selectedCalendars.remove(at: index)
                  } else {
                    selectedCalendars.append(calendar.calendarIdentifier)
                  }
                }) {
                  HStack {
                    Image(systemName: selectedCalendars.contains(calendar.calendarIdentifier) ? "checkmark.circle.fill" : "circle")
                      .foregroundColor(Color(cgColor: calendar.cgColor))
                      .font(.system(size: 25))
                    Text(calendar.title)
                  }
                }
                .listRowBackground(Color("ListBackground"))
            }
          }
        }
      }
      .listStyle(.plain)
      .navigationBarTitle("Select Calendars")
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarBackButtonHidden(true)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(
            action: {
              UserDefaults.standard.set(Array(selectedCalendars), forKey: "selectedCalendars")
              presentationMode.wrappedValue.dismiss()
              eventStoreViewModel.fetchEvents()
            }) {
              Text("Done")
            }
        }
      }
    } //end of ZStack
    .onAppear() {
      eventStoreViewModel.fetchCalendars()
      
      let appearance = UINavigationBarAppearance()
      appearance.backgroundColor = UIColor(Color("NavigationBackground"))
      UINavigationBar.appearance().standardAppearance = appearance
      UINavigationBar.appearance().scrollEdgeAppearance = appearance
      UINavigationBar.appearance().tintColor = UIColor(Color("AccentColor"))
      
      DispatchQueue.main.async {
        if let selectedCalendars = UserDefaults.standard.object(forKey: "selectedCalendars") as? [String] {
          self.selectedCalendars = selectedCalendars
        }
      }
      
      Mixpanel.mainInstance().track(event: "Calendars View")
    }
  }
}

struct Calendars_Previews: PreviewProvider {
  static var previews: some View {
    Calendars()
  }
}
