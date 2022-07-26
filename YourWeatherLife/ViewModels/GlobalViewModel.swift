//
//  GlobalViewModel.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/11/22.
//

import Foundation
import CoreData
import Mixpanel
import OSLog

class GlobalViewModel: ObservableObject {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "GlobalViewModel")
  
  static let shared = GlobalViewModel()

  private var viewContext = LocalPersistenceController.shared.container.viewContext
  private var viewCloudContext = CloudPersistenceController.shared.container.viewContext
  
  @Published var returningFromChildView = false
  @Published var today = Dates.shared.getTodayDateString(format: "yyyy-MM-dd")
  @Published var weekend = Dates.shared.getThisWeekendDateStrings(format: "yyyy-MM-dd")
  @Published var networkOnline = true {
    didSet {
      guard oldValue != networkOnline else { return }
      if networkOnline {
        logger.debug("Network online now!")
        NotificationCenter.default.post(name: .locationUpdatedEvent, object: nil)
      }
    }
  }
  
  private init() {
    checkInternetConnection(closure: { connected in
      DispatchQueue.main.async {
        self.networkOnline = connected
      }
    })

    if !UserDefaults.standard.bool(forKey: "automaticLocation") {
      guard let _ = UserDefaults.standard.string(forKey: "manualLocationData") else {
        let authorizationStatus = LocationViewModel.shared.authorizationStatus
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
          UserDefaults.standard.set(true, forKey: "automaticLocation")
        } else {
          UserDefaults.standard.set(false, forKey: "automaticLocation")
          UserDefaults.standard.set("98034", forKey: "manualLocationData")
        }
        return
      }
    }
  }
  
  func checkInternetConnection(closure: @escaping (Bool) -> Void) {
    if let url = URL(string: "https://weather.solutions/test.html") {
      var request = URLRequest(url: url)
      request.httpMethod = "HEAD"
      request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
      request.timeoutInterval = 3
      let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
        closure(error == nil)
      })
      task.resume()
    } else {
      closure(false)
    }
  }
  
  func fetchAppVersionNumber() -> String {
    var appVersion = ""
    if let buildNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
      appVersion = buildNumber
    }
    return appVersion
  }
  
  func fetchBuildNumber() -> String {
    var buildNum = ""
    if let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
      buildNum = buildNumber
    }
    return buildNum
  }
}
