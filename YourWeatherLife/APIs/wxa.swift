//
//  wxa.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/24/22.
//

import Foundation
import CoreLocation

struct wxa {
  
  static let shared = wxa()
  
  private init() { }
  
  private var apiKey = APISettings.shared.fetchAPISettings().wxaApiKey
  private var urlBase = APISettings.shared.fetchAPISettings().wxaUrlBase

  func getNWSPointsURL() async -> String {
    let url = "https://api.weather.gov/points/"
    return url
  }
  
  func getNWSPointsURLwithLocation() async -> String {
    let location = await getLocation()
    let url = "https://api.weather.gov/points/" + location
    return url
  }
  
  func getSearchURL() async -> String {
    var url = ""
    if !urlBase.isEmpty && !apiKey.isEmpty {
      url = urlBase + "/search.json" + "?key=" + apiKey
    }
    return url
  }
  
  func getCurrentWeatherURL() async -> String {
    var url = ""
    let location = await getLocation()
    if !urlBase.isEmpty && !apiKey.isEmpty {
      url = urlBase + "/current.json" + "?key=" + apiKey + "&q=" + location
    }
    return url
  }
  
  func getWeatherForecastURL(days: String) async -> String {
    var url = ""
    let location = await getLocation()
    if !urlBase.isEmpty && !apiKey.isEmpty {
      url = urlBase + "/forecast.json" + "?key=" + apiKey + "&q=" + location + "&days=" + days
    }
    return url
  }
  
  private func getLocation() async -> String {
    let authorizationStatus = LocationViewModel.shared.authorizationStatus
    if !UserDefaults.standard.bool(forKey: "automaticLocation") {
      guard let manualLocationData = UserDefaults.standard.string(forKey: "manualLocationData") else {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
          UserDefaults.standard.set(true, forKey: "automaticLocation")
          return await getAutomaticLocation()
        } else {
          UserDefaults.standard.set(false, forKey: "automaticLocation")
          UserDefaults.standard.set("98034", forKey: "manualLocationData")
          return "98034"
        }
      }
      return manualLocationData.isEmpty ? "98034" : manualLocationData
    } else {
      if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
        return await getAutomaticLocation()
      } else {
        return "98034"
      }
    }
  }
  
  private func getAutomaticLocation() async -> String {
    let locationManager = LocationViewModel.shared.locationManager
    if let location = locationManager.location {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        return "\(latitude),\(longitude)"
    } else {
      return "98034"
    }
  }
}
