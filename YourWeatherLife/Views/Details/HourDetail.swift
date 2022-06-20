//
//  HourDetail.swift
//  YourDay
//
//  Created by David Barkman on 6/12/22.
//

import SwiftUI
import Mixpanel

struct HourDetail: View {
  var body: some View {
    ZStack {
      BackgroundColor()
      List {
        Group {
          Text("Temp: 85°")
          Text("Feels like: 84°")
          Text("Humidity: 60%")
          Text("Dewpoint: 68°")
          Text("Chance of rain: 60%")
          Text("Precipitation Amount: 1/2 in")
        }
        .listRowBackground(Color("ListBackground"))
        Group {
          Text("Winds: 5 mph")
          Text("Gusting to: 6 mph")
          Text("From the: west")
          Text("Pressure: 30.01 in")
          Text("Visibility: 10 mi")
          Text("UV Index: 2")
        }
        .listRowBackground(Color("ListBackground"))
      } //end of List
      .navigationTitle("Today at 6p")
      .listStyle(.plain)
    } //end of ZStack
    .onAppear() {
      let appearance = UINavigationBarAppearance()
      appearance.backgroundColor = UIColor(Color("NavigationBackground"))//.opacity(0.9))
      UINavigationBar.appearance().standardAppearance = appearance
      UINavigationBar.appearance().scrollEdgeAppearance = appearance
      Mixpanel.mainInstance().track(event: "HourDetail View")
    }
  }
}

struct HourDetail_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      HourDetail()
    }
  }
}
