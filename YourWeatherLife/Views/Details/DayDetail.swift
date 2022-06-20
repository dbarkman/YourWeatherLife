//
//  DayDetail.swift
//  YourDay
//
//  Created by David Barkman on 6/12/22.
//

import SwiftUI
import Mixpanel

struct DayDetail: View {
  
  var body: some View {
    ZStack {
      BackgroundColor()
      List {
        Section(header: Text("Summary")) {
          Text("Coldest: 68° at 4a°")
          Text("Sunrise: 72° at 7:14a")
          Text("Warmest: 83° at 3p")
          Text("Rain: 80% at 4p")
          Text("Sunset: 76° at 8:13p")
        }
        .listRowBackground(Color("ListBackground"))
        Section(header: Text("Details")) {
          Group {
            NavigationLink(destination: HourDetail()) {
              Text("7a 🌗 72°")
            }
            Text("8a ☀️ 74°")
            Text("9a ☀️ 75°")
            Text("10a ☀️ 76°")
            Text("11a ☀️ 77°")
            Text("12p ☀️ 79°")
            Text("1p ☀️ 80°")
            Text("2p ☀️ 82°")
            Text("3p ☀️ 83°")
            Text("4p ☀️ 82°")
          }
          Group {
            Text("5p ☀️ 80°")
            NavigationLink(destination: HourDetail()) {
              Text("6p ☀️ 78°")
            }
            Text("7p ☀️ 77°")
            Text("8p ☀️ 76°")
            Text("9p 🌗 74°")
            Text("10p 🌗 72°")
            Text("11p 🌗 70°")
          }
        } //end of Section
        .listRowBackground(Color("ListBackground"))
      } //end of List
      .navigationTitle("Today")
      .listStyle(.plain)
    } //end of ZStack
    .onAppear() {
      let appearance = UINavigationBarAppearance()
      appearance.backgroundColor = UIColor(Color("NavigationBackground"))//.opacity(0.9))
      UINavigationBar.appearance().standardAppearance = appearance
      UINavigationBar.appearance().scrollEdgeAppearance = appearance
      Mixpanel.mainInstance().track(event: "DayDetail View")
    }
  }
}


struct DayDetail_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      DayDetail()
    }
  }
}
