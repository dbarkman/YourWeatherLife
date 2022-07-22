//
//  tgw.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/24/22.
//

import Foundation
import CoreLocation
import OSLog

struct tgw {
  
  static func getCurrentWeatherURL() async -> String {
    let apiKey = APISettings.fetchAPISettings().tgwApiKey
    let urlBase = APISettings.fetchAPISettings().tgwUrlBase
    var url = ""
    let location = await getLocation()
    if !urlBase.isEmpty && !apiKey.isEmpty {
      url = urlBase + "/current.json" + "?key=" + apiKey + "&q=" + location
    }
    return url
  }
  
  static func getWeatherForecastURL(days: String) async -> String {
    let apiKey = APISettings.fetchAPISettings().tgwApiKey
    let urlBase = APISettings.fetchAPISettings().tgwUrlBase
    var url = ""
    let location = await getLocation()
    if !urlBase.isEmpty && !apiKey.isEmpty {
      url = urlBase + "/forecast.json" + "?key=" + apiKey + "&q=" + location + "&days=" + days
    }
    return url
  }
  
  private static func getLocation() async -> String {
    var location = ""
    if UserDefaults.standard.bool(forKey: "automaticLocation") {
      location = await getAutomaticLocation()
    } else {
      if let manualLocationData = UserDefaults.standard.string(forKey: "manualLocationData") {
        location = manualLocationData
      } else {
        location = "98034"
      }
    }
    return location
  }
  
  private static func getAutomaticLocation() async -> String {
    var finalLocation = ""
    let locationManager = CLLocationManager()
    let authorizationStatus = locationManager.authorizationStatus
    if (authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse) {
      if let location = locationManager.location {
        let geocoder = CLGeocoder()
        do {
          let reverseGeocodeLocation = try await geocoder.reverseGeocodeLocation(location)
          if reverseGeocodeLocation.count > 0 {
            return reverseGeocodeLocation[0].postalCode ?? "98034"
          }
          let latitude = location.coordinate.latitude
          let longitude = location.coordinate.longitude
          finalLocation = "\(latitude),\(longitude)"
        } catch {
          finalLocation = "98034"
          print("Couldn't reverse geocode location. 😭 \(error.localizedDescription)")
        }
      } else {
        finalLocation = "98034"
      }
    } else {
      finalLocation = "98034"
    }
    return finalLocation
  }
}
