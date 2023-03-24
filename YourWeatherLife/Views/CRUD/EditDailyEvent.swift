//
//  EditDailyEvent.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/11/22.
//

import SwiftUI
import Mixpanel
import OSLog
import FirebaseAnalytics

struct EditDailyEvent: View {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "EditDailyEvent")
  
  @Environment(\.presentationMode) var presentationMode
  @Environment(\.colorScheme) var colorScheme
  
  @StateObject private var eventViewModel = EventViewModel.shared
  
  @State private var selection: Set<String> = []

  @State var addEvent = false
  @State var eventName = ""
  @State var startTimeDate = Dates.shared.roundTimeUp(date: Date())
  @State var endTimeDate = Dates.shared.roundTimeUp(date: Date())
  @State var daysSelected = [1,2,3,4,5,6,7]
  
  var oldEventName = ""
  
  @Binding var returningFromModal: Bool
  
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
              .autocapitalization(.words)
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
          NavigationLink(destination: Days(daysSelected: $daysSelected)) {
            Text("Select Days for Event Forecast")
          }
          NavigationLink(destination: Days(daysSelected: $daysSelected)) {
            HStack {
              Image(systemName: "chevron.right")
                .symbolRenderingMode(.monochrome)
                .foregroundColor(colorScheme == .dark ? .white : .black)
              Text(eventViewModel.daysSelected)
            }
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
              saveEvent()
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
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button(action: {
          presentationMode.wrappedValue.dismiss()
        }) {
          Text("Cancel")
        }
      }
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: {
          saveEvent()
        }) {
          Text("Save")
        }
      }
    }
    .onAppear() {
      let appearance = UINavigationBarAppearance()
      appearance.backgroundColor = UIColor(Color("NavigationBackground"))
      UINavigationBar.appearance().standardAppearance = appearance
      UINavigationBar.appearance().scrollEdgeAppearance = appearance
      UINavigationBar.appearance().tintColor = UIColor(Color("AccentColor"))
      Mixpanel.mainInstance().track(event: "EditDailyEvent View")
      Analytics.logEvent("View", parameters: ["view_name": "EditDailyEvent"])

      if eventViewModel.returningFromDays {
        eventViewModel.returningFromDays = false
      } else {
        eventViewModel.convertSelectedInts(selectedInts: &daysSelected)
        eventViewModel.selectedDays = daysSelected
      }
    }
  }
  
  func saveEvent() {
    eventViewModel.saveEvent(eventName: eventName, startTimeDate: startTimeDate, endTimeDate: endTimeDate, oldEventName: oldEventName, addEvent: addEvent, closure: { success in
      if success {
        returningFromModal = true
        presentationMode.wrappedValue.dismiss()
      }
    })
  }
}

//struct EditDailyEvent_Previews: PreviewProvider {
//  static var previews: some View {
//    NavigationStack {
//      EditDailyEvent(eventName: "", startTimeDate: Date(), endTimeDate: Date()).environment(\.colorScheme, .dark)
//    }
//    .accentColor(Color("AccentColor"))
//  }
//}
