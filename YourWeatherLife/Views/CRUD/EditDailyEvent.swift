//
//  EditDailyEvent.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/11/22.
//

import SwiftUI
import Mixpanel

struct EditDailyEvent: View {
  
  @Environment(\.presentationMode) var presentationMode
  
  @StateObject private var eventViewModel = EventViewModel()
  
  @State var addEvent = false
  @State var eventName = ""
  @State var startTimeDate = Dates.roundTimeUp(date: Date())
  @State var endTimeDate = Dates.roundTimeUp(date: Date())
  @State var showFeedback = false
  
  var oldEventName = ""
  
  var body: some View {
    ZStack {
      BackgroundColor()
      List {
        Section() {
          HStack {
            Text("Event Name:")
            TextField("event name", text: $eventName)
              .textFieldStyle(RoundedBorderTextFieldStyle())
              .environment(\.colorScheme, .light)
          }
          HStack {
            Text("Event Start Time:")
            DatePicker("", selection: $startTimeDate, displayedComponents: .hourAndMinute)
              .labelsHidden()
              .environment(\.colorScheme, .dark)
          }
          HStack {
            Text("Event End Time:")
            DatePicker("", selection: $endTimeDate, displayedComponents: .hourAndMinute)
              .labelsHidden()
              .environment(\.colorScheme, .dark)
              .foregroundColor(.white)
          }
          Text("for a more precise forecast, create events lasting 1-2 hours")
            .font(.footnote)
          if !eventViewModel.eventSaveResult.isEmpty {
            HStack {
              Text(eventViewModel.eventSaveResult)
              Spacer()
              Text("OK")
                .onTapGesture(perform: {
                  withAnimation() {
                    eventViewModel.eventSaveResult = ""
                  }
                })
            }
            .listRowBackground(Color.red.opacity(0.75))
          }
          Button(action: {
            withAnimation() {
              eventViewModel.saveEvent(eventName: eventName, startTimeDate: startTimeDate, endTimeDate: endTimeDate, oldEventName: oldEventName, addEvent: addEvent, closure: { success in
                if success {
                  presentationMode.wrappedValue.dismiss()
                }
              })
            }
          }, label: {
            Text("Save")
              .font(.title2)
              .foregroundColor(Color("AccentColor"))
          })
        }
        .listRowBackground(Color("ListBackground"))
      } //end of List
      .listStyle(.plain)
      .navigationBarTitle(addEvent ? "Add Event" : "Edit Event")
    } //end of ZStack
    .onAppear() {
      let appearance = UINavigationBarAppearance()
      appearance.backgroundColor = UIColor(Color("NavigationBackground"))//.opacity(0.9))
      UINavigationBar.appearance().standardAppearance = appearance
      UINavigationBar.appearance().scrollEdgeAppearance = appearance
      Mixpanel.mainInstance().track(event: "EditDailyEvent View")
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        if addEvent {
          Button(action: {
            presentationMode.wrappedValue.dismiss()
          }) {
            Text("Cancel")
          }
        }
      }
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: {
          eventViewModel.saveEvent(eventName: eventName, startTimeDate: startTimeDate, endTimeDate: endTimeDate, oldEventName: oldEventName, addEvent: addEvent, closure: { success in
            if success {
              presentationMode.wrappedValue.dismiss()
            }
          })
        }) {
          Text("Save")
        }
      }
    }
  }
}

struct EditDailyEvent_Previews: PreviewProvider {
  static var previews: some View {
    EditDailyEvent(eventName: "", startTimeDate: Date(), endTimeDate: Date()).environment(\.colorScheme, .dark)
  }
}
