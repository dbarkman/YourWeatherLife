//
//  DailyEvents.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/10/22.
//

import SwiftUI
import Mixpanel

struct DailyEvents: View {

  var body: some View {
    ZStack {
      BackgroundColor()
      List {
        Section(header: Text("Repeating Weekday Events")) {
          NavigationLink(destination: EditDailyEvent(eventName: "Morning Commute", eventStartTime: "7a", eventEndTime: "9a")) {
            HStack {
              Text("Morning Commute")
              Spacer()
              Text("7a - 9a")
            }
          }
          NavigationLink(destination: EditDailyEvent(eventName: "Lunch", eventStartTime: "11a", eventEndTime: "1p")) {
            HStack {
              Text("Lunch")
              Spacer()
              Text("11a - 1p")
            }
          }
          NavigationLink(destination: EditDailyEvent(eventName: "Afternoon Commute", eventStartTime: "4p", eventEndTime: "6p")) {
            HStack {
              Text("Afternoon Commute")
              Spacer()
              Text("4p - 6p")
            }
          }
        }
        .listRowBackground(Color("ListBackground"))
        Section(header: Text("Repeating Weekend Events")) {
          NavigationLink(destination: EditDailyEvent(eventName: "Lunch", eventStartTime: "11a", eventEndTime: "1p")) {
            HStack {
              Text("Lunch")
              Spacer()
              Text("11a - 1p")
            }
          }
        }
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
      Mixpanel.mainInstance().track(event: "DailyEvents View")
    }
  }
}

struct DailyEvents_Previews: PreviewProvider {
  static var previews: some View {
    DailyEvents()
  }
}
