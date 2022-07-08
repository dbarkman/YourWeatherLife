//
//  APISettings.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/18/22.
//

import Foundation

struct APISettings {
  static func fetchAPISettings() -> WeatherSolutions {
    var apiSettings = WeatherSolutions()
    if  let path = Bundle.main.path(forResource: "weatherSolutions", ofType: "plist"),
        let xml = FileManager.default.contents(atPath: path)
    {
      do {
        let api = try PropertyListDecoder().decode(WeatherSolutions.self, from: xml)
        apiSettings = api
      } catch {
        print("API settings decoding problem. 😭 \(error.localizedDescription)")
      }
    }
    return apiSettings
  }
}
