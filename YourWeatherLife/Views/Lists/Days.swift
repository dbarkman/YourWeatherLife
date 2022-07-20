//
//  Days.swift
//  YourWeatherLife
//
//  Created by David Barkman on 7/18/22.
//

import SwiftUI
import Mixpanel

struct Days: View {
  
  @EnvironmentObject private var eventViewModel: EventViewModel
  @Environment(\.presentationMode) var presentationMode

  @State private var isEditMode: EditMode = .active
  @Binding var selection: Set<String>

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
      List(days, id: \.self, selection: $selection) { day in
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
            presentationMode.wrappedValue.dismiss()
          }) {
            Text("Done")
          }
        }
      }
      .onAppear() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(Color("NavigationBackground"))//.opacity(0.9))
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(Color("AccentColor"))
        Mixpanel.mainInstance().track(event: "EditDailyEvent View")
        eventViewModel.returningFromChildView = true
      }
    .listStyle(.plain)
    } //end of ZStack
  }
}

struct Days_Previews: PreviewProvider {

  static var previews: some View {
    Text("Hello, world!")
//    Days()
  }
}
