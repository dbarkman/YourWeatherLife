//
//  Days.swift
//  YourWeatherLife
//
//  Created by David Barkman on 7/18/22.
//

import SwiftUI
import Mixpanel

struct Days: View {
  
  @Environment(\.presentationMode) var presentationMode

  @StateObject private var eventViewModel = EventViewModel.shared

  @State private var isEditMode: EditMode = .active
  
  @Binding var daysSelected: [Int]

  let days = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ]
  
  var body: some View {
    ZStack {
      BackgroundColor()
      List(days, id: \.self, selection: $eventViewModel.selectedSet) { day in
        Text(day)
          .listRowBackground(Color("ListBackground"))
      } //end of List
      .environment(\.editMode, self.$isEditMode)
      .listStyle(.plain)
      .navigationBarTitle("Select Days to Forecast")
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarBackButtonHidden(true)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: {
            eventViewModel.convertDaysSelected(selection: eventViewModel.selectedSet)
            presentationMode.wrappedValue.dismiss()
          }) {
            Text("Done")
          }
        }
      }
    .listStyle(.plain)
    } //end of ZStack
    .onAppear() {
      let appearance = UINavigationBarAppearance()
      appearance.backgroundColor = UIColor(Color("NavigationBackground"))
      UINavigationBar.appearance().standardAppearance = appearance
      UINavigationBar.appearance().scrollEdgeAppearance = appearance
      UINavigationBar.appearance().tintColor = UIColor(Color("AccentColor"))
      Mixpanel.mainInstance().track(event: "Days View")
      eventViewModel.returningFromDays = true
    }
  }
}

struct Days_Previews: PreviewProvider {

  static var previews: some View {
    Text("Hello, world!")
//    Days()
  }
}
