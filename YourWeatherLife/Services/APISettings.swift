//
//  APISettings.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/18/22.
//

import Foundation

struct APISettings {
  
  static let shared = APISettings()
  
  private init() { }
  
  func fetchAPISettings() -> API {
    var apiSettings = API()
    if  let path = Bundle.main.path(forResource: "api", ofType: "plist"),
        let xml = FileManager.default.contents(atPath: path)
    {
      do {
        let api = try PropertyListDecoder().decode(API.self, from: xml)
        apiSettings = api
      } catch {
        print("API settings decoding problem. 😭 \(error.localizedDescription)")
      }
    }
    return apiSettings
  }
}
