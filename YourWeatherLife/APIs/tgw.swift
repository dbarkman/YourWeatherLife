//
//  tgw.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/24/22.
//

import Foundation
import CoreLocation

struct tgw {
  
  static let shared = tgw()
  
  private init() { }
  
  func getCurrentWeatherURL() async -> String {
    let apiKey = APISettings.shared.fetchAPISettings().tgwApiKey
    let urlBase = APISettings.shared.fetchAPISettings().tgwUrlBase
    var url = ""
    let location = await getLocation()
    if !urlBase.isEmpty && !apiKey.isEmpty {
      url = urlBase + "/current.json" + "?key=" + apiKey + "&q=" + location
    }
    return url
  }
  
  func getWeatherForecastURL(days: String) async -> String {
    let apiKey = APISettings.shared.fetchAPISettings().tgwApiKey
    let urlBase = APISettings.shared.fetchAPISettings().tgwUrlBase
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
      let geocoder = CLGeocoder()
      do {
        let reverseGeocodeLocation = try await geocoder.reverseGeocodeLocation(location)
        if reverseGeocodeLocation.count > 0 {
          return reverseGeocodeLocation[0].postalCode ?? "98034"
        }
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        return "\(latitude),\(longitude)"
      } catch {
        print("Couldn't reverse geocode location. 😭 \(error.localizedDescription)")
        return "98034"
      }
    } else {
      return "98034"
    }
  }
}
