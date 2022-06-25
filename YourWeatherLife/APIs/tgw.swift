//
//  tgw.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/24/22.
//

import Foundation

struct tgw {

  static func getCurrentWeatherURL(_ api: API) -> String {
    var url = ""
    if !api.urlBase.isEmpty && !api.apiKey.isEmpty {
      url = api.urlBase + "/current.json" + "?key=" + api.apiKey + "&q=85215"
    }
    return url
  }

}
