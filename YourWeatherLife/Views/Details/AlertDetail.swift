//
//  AlertDetail.swift
//  YourWeatherLife
//
//  Created by David Barkman on 4/12/23.
//

import SwiftUI
import Mixpanel
import OSLog
import FirebaseAnalytics

struct AlertDetail: View {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "AlertDetail")

  @State private var showFeedback = false

  public var details: String
  public var event: String
  
  var body: some View {
    ZStack {
      BackgroundColor()
      List {
        Text(details)
          .listRowBackground(Color("ListBackground"))
      }
      .listStyle(.plain)
    }
    .navigationTitle(event)
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
      UINavigationBar.appearance().tintColor = UIColor(Color("AccentColor"))
      Mixpanel.mainInstance().track(event: "AlertDetail View")
      Analytics.logEvent("View", parameters: ["view_name": "AlertDetail"])
    }
  }
}

struct AlertDetail_Previews: PreviewProvider {
  static var previews: some View {
    AlertDetail(details: "", event: "")
  }
}
