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

  static func getCurrentWeatherURL(_ api: API) async -> String {
    var url = ""
    let location = await getLocation()
    if !api.urlBase.isEmpty && !api.apiKey.isEmpty {
      url = api.urlBase + "/current.json" + "?key=" + api.apiKey + "&q=" + location
    }
    return url
  }
  
  static func getWeatherForecastURL(_ api: API, days: String) async -> String {
    var url = ""
    let location = await getLocation()
    if !api.urlBase.isEmpty && !api.apiKey.isEmpty {
      url = api.urlBase + "/forecast.json" + "?key=" + api.apiKey + "&q=" + location + "&days=" + days
    }
    return url
  }
  
  static func getLocation() async -> String {
    var finalLocation = ""
    let locationManager = CLLocationManager()
    let authorizationStatus = locationManager.authorizationStatus
    if (authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse) {
      if let location = locationManager.location {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        finalLocation = ("\(latitude),\(longitude)")
      } else {
        finalLocation = "98034"
      }
    } else {
      finalLocation = "98034"
    }
    return finalLocation
  }
}
