//
//  aowm.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/24/22.
//

import Foundation

struct aowm {
  
  static let shared = aowm()
  
  private init() { }
  
  func getCurrentWeatherURL(_ api: API) -> String {
    var url = ""
    if !api.urlBase.isEmpty && !api.apiKey.isEmpty {
      url = api.urlBase + "/weather" + "?appid=" + api.apiKey + "&lat=33.4805859&lon=-111.7018452" + "&units=metric"
    }
    return url
  }
  
}
