//
//  tgw.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/24/22.
//

import Foundation
import OSLog

struct tgw {

  static func getCurrentWeatherURL(_ api: API) -> String {
    var url = ""
    if !api.urlBase.isEmpty && !api.apiKey.isEmpty {
      url = api.urlBase + "/current.json" + "?key=" + api.apiKey + "&q=85215"
    }
    return url
  }
  
  static func getWeatherForecastURL(_ api: API, days: String) -> String {
    var url = ""
    if !api.urlBase.isEmpty && !api.apiKey.isEmpty {
      url = api.urlBase + "/forecast.json" + "?key=" + api.apiKey + "&q=85215" + "&days=" + days
    }
    return url
  }
  
}
