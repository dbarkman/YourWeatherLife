//
//  Alerts.swift
//  YourWeatherLife
//
//  Created by David Barkman on 4/6/23.
//

import SwiftUI
import Mixpanel
import OSLog
import FirebaseAnalytics

struct Alerts: View {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "Alerts")
  
  @StateObject private var alertsViewModel = AlertsViewModel.shared
  
  @State private var showNotificationSettings = false
  @State private var showFeedback = false

    var body: some View {
      NavigationStack {
        ZStack {
          BackgroundColor()
          VStack {
            Picker("", selection: $alertsViewModel.location) {
              Text("County").tag(0)
              Text("State").tag(1)
              Text("All").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            List(alertsViewModel.alertsList, id: \.self) { alert in
              ZStack(alignment: .leading) {
                NavigationLink(destination: AlertDetail(details: alert.description ?? "no description available", event: alert.event ?? "")) { }
                  .opacity(0)
                Text(alert.headline ?? "")
              } //end of ZStack
              .listRowBackground(Color("ListBackground"))
            } //end of List
            .listStyle(.plain)
            .refreshable {
              await alertsViewModel.getAlerts()
            }
            .task {
              await alertsViewModel.getAlerts()
            }
          }
          .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
              Button(action: {
                showNotificationSettings = true
              }, label: {
                Image(systemName: "line.3.horizontal")
                  .symbolRenderingMode(.monochrome)
              })
            }
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
          .sheet(isPresented: $showNotificationSettings) {
            NotificationSettingsModal()
          }
          .navigationTitle("NWS Alerts")
        }
        .onAppear() {
          UINavigationBar.appearance().tintColor = UIColor(Color("AccentColor"))
          Mixpanel.mainInstance().track(event: "Alerts View")
          Analytics.logEvent("View", parameters: ["view_name": "Alerts"])
        }
      }
    }
}

struct Alerts_Previews: PreviewProvider {
    static var previews: some View {
        Alerts()
    }
}
