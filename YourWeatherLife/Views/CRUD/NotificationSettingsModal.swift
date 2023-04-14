//
//  NotificationSettingsModal.swift
//  YourWeatherLife
//
//  Created by David Barkman on 4/13/23.
//

import SwiftUI
import Mixpanel
import OSLog
import FirebaseAnalytics

struct NotificationSettingsModal: View {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "NotificationSettingsModal")
  
  @Environment(\.presentationMode) var presentationMode
  
  @State private var sendPush = false
  @State private var sendPushForState = false
  @State private var sendPushForAll = false
  @State private var notificationsAllowed = false

  var body: some View {
    NavigationStack {
      List {
        Toggle(isOn: $sendPush) {
          Text("Send Notifications?")
          Text("This is normally for your county.")
            .font(.footnote)
        }
        if sendPush {
          if notificationsAllowed {
            Toggle(isOn: $sendPushForState) {
              Text("Send Statewide Notifications?")
            }
            Toggle(isOn: $sendPushForAll) {
              Text("Send All U.S. Notifications?")
              Text("This will result in hundreds of notifications per day.")
                .font(.footnote)
            }
          } else {
            Text("\"Your Weather Life\" is not currently allowed to send you notifications. To enable notifications, tap Open Settings below and grant Notifications permission to this app.")
            Button(action: {
              withAnimation() {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                  UIApplication.shared.open(settingsUrl)
                }
              }
            }, label: {
              Text("Open Settings")
            })
          }
        }
      }
      .listStyle(.plain)
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
            saveNotificationSettings()
          }) {
            Text("Save")
          }
        }
      }
      .onChange(of: sendPushForAll) { _ in
        if sendPushForAll {
          sendPushForState = true
        }
      }
      .onAppear() {
        Mixpanel.mainInstance().track(event: "NotificationSettings View")
        Analytics.logEvent("View", parameters: ["view_name": "NotificationSettings"])
        UNUserNotificationCenter.current().getNotificationSettings { settings in
          guard (settings.authorizationStatus == .authorized) || (settings.authorizationStatus == .provisional) else { return }
          if settings.alertSetting == .enabled {
            notificationsAllowed = true
          } else {
            notificationsAllowed = false
          }
        }
        if UserDefaults.standard.bool(forKey: "sendPush") {
          self.sendPush = true
          if UserDefaults.standard.bool(forKey: "sendArea") {
            self.sendPushForState = true
          } else {
            self.sendPushForState = false
          }
          if UserDefaults.standard.bool(forKey: "sendAll") {
            self.sendPushForAll = true
            self.sendPushForState = true
          } else {
            self.sendPushForAll = false
          }
        } else {
          self.sendPush = false
        }
      }
    }
  }
  
  func saveNotificationSettings() {
    if sendPush {
      UserDefaults.standard.set(true, forKey: "sendPush")
      if sendPushForState == true {
        UserDefaults.standard.set(true, forKey: "sendArea")
      } else {
        UserDefaults.standard.set(false, forKey: "sendArea")
      }
      if sendPushForAll == true {
        UserDefaults.standard.set(true, forKey: "sendAll")
        UserDefaults.standard.set(true, forKey: "sendArea")
      } else {
        UserDefaults.standard.set(false, forKey: "sendAll")
      }
    } else {
      UserDefaults.standard.set(false, forKey: "sendPush")
    }
    Task {
      let token = UserDefaults.standard.string(forKey: "apnsToken") ?? ""
      var debug = 0
#if DEBUG
      debug = 1
#endif
      await AsyncAPI.shared.saveToken(token: token, debug: debug)
    }
    presentationMode.wrappedValue.dismiss()
  }
}

struct NotificationSettingsModal_Previews: PreviewProvider {
  static var previews: some View {
    NotificationSettingsModal()
  }
}
