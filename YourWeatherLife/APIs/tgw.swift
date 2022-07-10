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
  
  static func getLocation() async -> String {
    var finalLocation = ""
    let locationManager = CLLocationManager()
    let authorizationStatus = locationManager.authorizationStatus
    if (authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse) {
      if let location = locationManager.location {
        let geocoder = CLGeocoder()
        let reverseGeocodeLocation = try? await geocoder.reverseGeocodeLocation(location)
        if let reverseGeocodeLocations = reverseGeocodeLocation {
          if reverseGeocodeLocations.count > 0 {
            return reverseGeocodeLocations[0].postalCode ?? "98034"
          }
        }
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        finalLocation = "\(latitude),\(longitude)"
      } else {
        finalLocation = "98034"
      }
    } else {
      finalLocation = "98034"
    }
    return finalLocation
  }
}
