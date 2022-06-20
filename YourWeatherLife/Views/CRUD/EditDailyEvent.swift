//
//  EditDailyEvent.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/11/22.
//

import SwiftUI
import Mixpanel

struct EditDailyEvent: View {
  
  @State public var eventName = ""
  @State public var eventStartTime = ""
  @State public var eventEndTime = ""
  
  var body: some View {
    ZStack {
      BackgroundColor()
      List {
        Section(footer: Text("for a more precise forecast, create events lasting 1-2 hours")) {
          HStack {
            Text("Event Name:")
            TextField("event name", text: $eventName)
              .textFieldStyle(RoundedBorderTextFieldStyle())
          }
          HStack {
            Text("Event Start:")
            TextField("start time", text: $eventStartTime)
              .textFieldStyle(RoundedBorderTextFieldStyle())
            
          }
          HStack {
            Text("Event End:")
            TextField("end time", text: $eventEndTime)
              .textFieldStyle(RoundedBorderTextFieldStyle())
          }
        }
        .listRowBackground(Color("ListBackground"))
      } //end of List
      .listStyle(.plain)
    } //end of ZStack
    .onAppear() {
      let appearance = UINavigationBarAppearance()
      appearance.backgroundColor = UIColor(Color("NavigationBackground"))//.opacity(0.9))
      UINavigationBar.appearance().standardAppearance = appearance
      UINavigationBar.appearance().scrollEdgeAppearance = appearance
      Mixpanel.mainInstance().track(event: "EditDailyEvent View")
    }
  }
}

struct EditDailyEvent_Previews: PreviewProvider {
  static var previews: some View {
    EditDailyEvent(eventName: "", eventStartTime: "", eventEndTime: "")
  }
}
