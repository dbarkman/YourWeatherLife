//
//  GetAllData.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/29/22.
//

import Foundation
import OSLog

struct GetAllData {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "GetAllData")

  static let shared = GetAllData()
    
  private init() { }
  
  func fetchCurrentConditions() -> Bool {
    logger.debug("Trying to fetch current conditions.")
    let now = Date()
    var nextUpdate: Date
    if let currentConditionsNextUpdate = UserDefaults.standard.object(forKey: "currentConditionsNextUpdate") as? Date {
      nextUpdate = currentConditionsNextUpdate
    } else {
      nextUpdate = Date(timeIntervalSince1970: 0)
    }
    if now > nextUpdate {
      logger.debug("Fetching current conditions.")
      nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date()) ?? Date()
      UserDefaults.standard.set(nextUpdate, forKey: "currentConditionsNextUpdate")
      return true
    } else {
      logger.debug("Next current conditions update available at \(nextUpdate)")
    }
    return false
  }
  
  func updateForecasts() async {
    logger.debug("Trying to fetch forecasts.")
    let now = Date()
    var nextUpdate: Date
    if let forecastsNextUpdate = UserDefaults.standard.object(forKey: "forecastsNextUpdate") as? Date {
      nextUpdate = forecastsNextUpdate
    } else {
      nextUpdate = Date(timeIntervalSince1970: 0)
    }
    if now > nextUpdate {
      logger.debug("Fetching forecasts.")
      nextUpdate = Calendar.current.date(byAdding: .minute, value: 10, to: Date()) ?? Date()
      UserDefaults.standard.set(nextUpdate, forKey: "forecastsNextUpdate")
      await TGW_ForecastProvider.shared.fetchForecast()
      NotificationCenter.default.post(name: .forecastInsertedEvent, object: nil)
      logger.debug("Days and Hours imported successfully! - location 🎉")
    } else {
      logger.debug("Next forecast update available at \(nextUpdate)")
    }
  }
}
