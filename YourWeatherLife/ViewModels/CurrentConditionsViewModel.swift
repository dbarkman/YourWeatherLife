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
  
  var data = Data()

  @Published var current: Current?
  
  init() {
    NotificationCenter.default.addObserver(self, selector: #selector(overrideUpdateCurrent), name: .locationUpdatedEvent, object: nil)
  }

  @objc func overrideUpdateCurrent() {
    let nextUpdate = Date(timeIntervalSince1970: 0)
    UserDefaults.standard.set(nextUpdate, forKey: "currentConditionsNextUpdate")
    updateCurrent()
  }

  func updateCurrent() {
    Task {
      await fetchCurrentWeather()
    }
  }

  func fetchCurrentWeather() async {
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
//    let api = await DataService().fetchPrimaryAPIFromLocal()
    let url = await tgw.getCurrentWeatherURL()
//    switch api.shortName {
//      case "tgw":
//        url = await tgw.getCurrentWeatherURL(api)
//      case "aowm":
//        url = aowm.getCurrentWeatherURL(api)
//      default:
//        logger.error("Couldn't determine the API by shortname. 😭")
//    }
    
    guard !url.isEmpty else { return }
    let urlRequest = URLRequest(url: URL(string: url)!)
    let session = URLSession.shared
    guard let (data, response) = try? await session.data(for: urlRequest), let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200
    else {
      logger.error("Failed to received valid response and/or data. 😭")
      return
    }
    Mixpanel.mainInstance().track(event: "Fetched Current Conditions")
    self.data = data
    
    let jsonDecoder = JSONDecoder()
    do {
      let tgwDecoder = try jsonDecoder.decode(TGW_CurrentConditionsDecoder.self, from: data)
      saveCurrentConditions(current: tgwDecoder.current)
      DispatchQueue.main.async {
        self.current = tgwDecoder.current
      }
//      switch api.shortName {
//        case "tgw":
//          let tgwDecoder = try jsonDecoder.decode(TGW_CurrentConditionsDecoder.self, from: data)
//          saveCurrentConditions(current: tgwDecoder.current)
//          DispatchQueue.main.async {
//            self.current = tgwDecoder.current
//          }
//        case "aowm":
//          let aowmDecoder = try jsonDecoder.decode(AOWM_CurrentConditionsDecoder.self, from: data)
//          saveCurrentConditions(current: aowmDecoder.current)
//          DispatchQueue.main.async {
//            self.current = aowmDecoder.current
//          }
//        default:
//          self.logger.error("Couldn't determine the Decoder by shortname. 😭")
//      }
    } catch {
      logger.error("Could not decode current conditions. 😭 \(error.localizedDescription)")
    }
  }
  
  func saveCurrentConditions(current: Current) {
    UserDefaults.standard.set(current.temperature, forKey: "currentConditionsTemperature")
    UserDefaults.standard.set(current.condition, forKey: "currentConditionsCondition")
    UserDefaults.standard.set(current.icon, forKey: "currentConditionsIcon")
    UserDefaults.standard.set(current.location, forKey: "currentConditionsLocation")
  }
}
