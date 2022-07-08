//
//  EditDailyEvent.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/11/22.
//

import SwiftUI
import Mixpanel

struct EditDailyEvent: View {
  
  @State var eventName = ""
  @State var eventStartTime = ""
  @State var eventEndTime = ""
  @State var showingFeedback = false

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
    .toolbar {
      ToolbarItem {
        Button(action: {
          showingFeedback.toggle()
        }) {
          Label("Feedback", systemImage: "star")
        }
        .sheet(isPresented: $showingFeedback) {
          FeedbackModal()
        }
      }
    }
  }
}

struct EditDailyEvent_Previews: PreviewProvider {
  static var previews: some View {
    EditDailyEvent(eventName: "", eventStartTime: "", eventEndTime: "")
  }
}
