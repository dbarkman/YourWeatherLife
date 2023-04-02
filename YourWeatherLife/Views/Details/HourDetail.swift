//
//  HourDetail.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/12/22.
//

import SwiftUI
import Mixpanel
import OSLog
import FirebaseAnalytics

struct HourDetail: View {

  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "HourDetail")
  
  @State private var showFeedback = false
  @State var hour = HourForecast()
  
  var navigationTitle: String

  var body: some View {
    ZStack {
      BackgroundColor()
      List {
        Group {
          HStack {
            Text("Temperature:")
              .fontWeight(.semibold)
            Text("\(hour.temperature)")
          }
          HStack {
            Text("Feels like:")
              .fontWeight(.semibold)
            Text("\(hour.feelsLike)")
          }
          HStack {
            Text("Humidity:")
              .fontWeight(.semibold)
            Text("\(hour.humidity)%")
          }
          HStack {
            Text("Dewpoint:")
              .fontWeight(.semibold)
            Text("\(hour.dewPoint)")
          }
          if hour.willItRain {
            HStack {
              Text("Chance of rain:")
                .fontWeight(.semibold)
              Text("\(hour.rainChance)%")
            }
            HStack {
              Text("Expectd Rain Amount:")
                .fontWeight(.semibold)
              Text("\(hour.precipAmount)")
            }
          }
          if hour.willItSnow {
            HStack {
              Text("Chance of snow:")
                .fontWeight(.semibold)
              Text("\(hour.snowChance)%")
            }
            HStack {
              Text("Expectd Snow Amount:")
                .fontWeight(.semibold)
              Text("\(hour.precipAmount)")
            }
          }
        }
        .listRowBackground(Color("ListBackground"))
        Group {
          HStack {
            Text("Winds:")
              .fontWeight(.semibold)
            Text("\(hour.wind)")
          }
          HStack {
            Text("Gusting to:")
              .fontWeight(.semibold)
            Text("\(hour.windGust)")
          }
          HStack {
            Text("From the:")
              .fontWeight(.semibold)
            Text("\(hour.windDirection)")
          }
          HStack {
            Text("Pressure:")
              .fontWeight(.semibold)
            Text("\(hour.pressure)")
          }
          HStack {
            Text("Visibility:")
              .fontWeight(.semibold)
            Text("\(hour.visibility)")
          }
          HStack {
            Text("UV Index:")
              .fontWeight(.semibold)
            Text("\(hour.uv)")
          }
        }
        .listRowBackground(Color("ListBackground"))
      } //end of List
      .listStyle(.plain)
    } //end of ZStack
    .navigationTitle(navigationTitle)
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
    .onAppear() {
//      let appearance = UINavigationBarAppearance()
//      appearance.backgroundColor = UIColor(Color("NavigationBackground"))
//      UINavigationBar.appearance().standardAppearance = appearance
//      UINavigationBar.appearance().scrollEdgeAppearance = appearance
      UINavigationBar.appearance().tintColor = UIColor(Color("AccentColor"))
      Mixpanel.mainInstance().track(event: "HourDetail View")
      Analytics.logEvent("View", parameters: ["view_name": "HourDetail"])
    }
  }
}

struct HourDetail_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      HourDetail(navigationTitle: "Hour")
    }
    .accentColor(Color("AccentColor"))
  }
}
