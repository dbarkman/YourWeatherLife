//
//  HourDetail.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/12/22.
//

import SwiftUI
import Mixpanel
import OSLog

struct HourDetail: View {

  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "HourDetail")
  
  @State var hour = HourForecast()
  @State var showFeedback = false

  var body: some View {
    ZStack {
      BackgroundColor()
      List {
        Group {
          Text("Temp: \(hour.temperature)")
          Text("Feels like: \(hour.feelsLike)")
          Text("Humidity: \(hour.humidity)%")
          Text("Dewpoint: \(hour.dewPoint)")
          if hour.willItRain {
            Text("Chance of rain: \(hour.rainChance)")
            Text("Expectd Rain Amount: \(hour.precipAmount)")
          }
          if hour.willItSnow {
            Text("Chance of snow: \(hour.snowChance)")
            Text("Expected Snow Amount: \(hour.precipAmount)")
          }
        }
        .listRowBackground(Color("ListBackground"))
        Group {
          Text("Winds: \(hour.wind)")
          Text("Gusting to: \(hour.windGust)")
          Text("From the: \(hour.windDirection)")
          Text("Pressure: \(hour.pressure)")
          Text("Visibility: \(hour.visibility)")
          Text("UV Index: \(hour.uv)")
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
      Mixpanel.mainInstance().track(event: "HourDetail View")
    }
    .toolbar {
      ToolbarItem {
        Button(action: {
          showFeedback.toggle()
        }) {
          Label("Feedback", systemImage: "star")
        }
        .sheet(isPresented: $showFeedback) {
          FeedbackModal()
        }
      }
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
