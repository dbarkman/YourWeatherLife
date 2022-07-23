//
//  CurrentConditionsViewModel.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/21/22.
//

import Foundation
import Mixpanel
import OSLog

class CurrentConditionsViewModel: ObservableObject {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "CurrentConditionsViewModel")
  
  static let shared = CurrentConditionsViewModel()
  var globalViewModel = GlobalViewModel.shared
  
  @Published var current: Current?
  
  var data = Data()
  
  private init() {
    NotificationCenter.default.addObserver(self, selector: #selector(overrideUpdateCurrent), name: .locationUpdatedEvent, object: nil)
  }

  @objc private func overrideUpdateCurrent() {
    if globalViewModel.networkOnline {
      logger.debug("Location updated, fetching current conditions.")
      let nextUpdate = Date(timeIntervalSince1970: 0)
      UserDefaults.standard.set(nextUpdate, forKey: "currentConditionsNextUpdate")
      updateCurrent()
    }
  }
  func updateCurrent() {
    Task {
      await fetchCurrentWeather()
    }
  }

  private func fetchCurrentWeather() async {
    guard GetAllData.shared.fetchCurrentConditions() else {
      let temperature = UserDefaults.standard.string(forKey: "currentConditionsTemperature") ?? "88"
      let condition = UserDefaults.standard.string(forKey: "currentConditionsCondition") ?? "Sunny"
      let icon = UserDefaults.standard.string(forKey: "currentConditionsIcon") ?? "day/113"
      let location = UserDefaults.standard.string(forKey: "currentConditionsLocation") ?? "Mesa"
      let current = Current(temperature: temperature, condition: condition, icon: icon, location: location)
      DispatchQueue.main.async {
        self.current = current
      }
      return
    }
    let url = await tgw.shared.getCurrentWeatherURL()
    if let url = URL(string: url) {
      let urlRequest = URLRequest(url: url)
      let session = URLSession.shared
      do {
        let (data, response) = try await session.data(for: urlRequest)
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
          Mixpanel.mainInstance().track(event: "Fetched Current Conditions")
          self.data = data
        } else {
          return
        }
      } catch {
        logger.error("Failed to received valid response and/or data. 😭 \(error.localizedDescription)")
      }
    }
    
    let jsonDecoder = JSONDecoder()
    do {
      let tgwDecoder = try jsonDecoder.decode(TGW_CurrentConditionsDecoder.self, from: data)
      saveCurrentConditions(current: tgwDecoder.current)
      DispatchQueue.main.async {
        self.current = tgwDecoder.current
      }
      logger.debug("Updated current conditions! 🎉")
    } catch {
      logger.error("Could not decode current conditions. 😭 \(error.localizedDescription)")
    }
  }
  
  private func saveCurrentConditions(current: Current) {
    UserDefaults.standard.set(current.temperature, forKey: "currentConditionsTemperature")
    UserDefaults.standard.set(current.condition, forKey: "currentConditionsCondition")
    UserDefaults.standard.set(current.icon, forKey: "currentConditionsIcon")
    UserDefaults.standard.set(current.location, forKey: "currentConditionsLocation")
  }
}
