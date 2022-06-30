//
//  GetAllData.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/29/22.
//

import Foundation
import OSLog

struct GetAllData {
  
  static let shared = GetAllData()
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "GetAllData")

  func getAllData() async {
    if !UserDefaults.standard.bool(forKey: "apisFetched") {
      await DataService().fetchAPIsFromCloud()
      UserDefaults.standard.set(true, forKey: "apisFetched")
      await getAllData()
    } else {
      await updateForecasts()
    }
  }
  
  func fetchCurrentConditions() -> Bool {
    let now = Date()
    var nextUpdate: Date
    if let currentConditionsNextUpdate = UserDefaults.standard.object(forKey: "currentConditionsNextUpdate") as? Date {
      nextUpdate = currentConditionsNextUpdate
    } else {
      nextUpdate = Date(timeIntervalSince1970: 0)
    }
    if now > nextUpdate {
      logger.debug("Current conditions expired at \(nextUpdate), getting new conditions")
      nextUpdate = Calendar.current.date(byAdding: .minute, value: 10, to: Date()) ?? Date()
      UserDefaults.standard.set(nextUpdate, forKey: "currentConditionsNextUpdate")
      return true
    } else {
      logger.debug("Current conditions still current, not fetching till: \(nextUpdate)")
    }
    return false
  }
  
  func updateForecasts() async {
    let now = Date()
    var nextUpdate: Date
    if let forecastsNextUpdate = UserDefaults.standard.object(forKey: "forecastsNextUpdate") as? Date {
      nextUpdate = forecastsNextUpdate
    } else {
      nextUpdate = Date(timeIntervalSince1970: 0)
    }
    if now > nextUpdate {
      logger.debug("Forecast expired at \(nextUpdate), getting new forecast")
      nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
      UserDefaults.standard.set(nextUpdate, forKey: "forecastsNextUpdate")
      await TGW_ForecastProvider.shared.fetchForecast()
    } else {
      logger.debug("Forecast still current, not fetching till: \(nextUpdate)")
    }
  }
}
