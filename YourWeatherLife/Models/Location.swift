//
//  Location.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/21/22.
//

import Foundation

struct Location: Decodable, Hashable {
  var name: String
  var region: String
  var country: String
  var lat: Double
  var lon: Double
  var tz_id: String
  var localtime_epoch: Double
  var localtime: String
}
