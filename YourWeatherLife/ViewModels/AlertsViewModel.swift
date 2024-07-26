//
//  AlertsViewModel.swift
//  YourWeatherLife
//
//  Created by David Barkman on 4/12/23.
//

import Foundation
import Mixpanel
import OSLog

class AlertsViewModel: ObservableObject {
  
  let logger = Logger(subsystem: "com.dbarkman.yourweatherlife", category: "AlertsViewModel")
  
  static let shared = AlertsViewModel()
  
  private init() { }
  
  @Published var alertsList: [Alert] = []
  @Published var location = 0 {
    didSet {
      guard oldValue != location else { return }
      Task {
        await self.getAlerts()
      }
    }
  }
  
  func getAlerts() async {
    if let response = await AsyncAPI.shared.getAlerts(location: location) {
      DispatchQueue.main.async {
        self.alertsList.removeAll()
        if response.alerts.isEmpty {
          var alert = Alert()
          alert.headline = "No active alerts for this region"
          self.alertsList.append(alert)
        } else {
          self.alertsList = response.alerts
        }
      }
    }
  }
}
