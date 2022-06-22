//
//  Current.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/20/22.
//

import Foundation

struct Current: Decodable, Hashable {
  var temp_c = 0.0
  var temp_f = 0.0
  var is_day = 1
  var condition: Condition
  var wind_mph = 0.0
  var wind_kph = 0.0
  var wind_degree = 0.0
  var wind_dir = "WSW"
  var pressure_mb = 0.0
  var pressure_in = 0.0
  var precip_mm = 0.0
  var precip_in = 0.0
  var humidity = 0.0
  var cloud = 0.0
  var feelslike_c = 0.0
  var feelslike_f = 0.0
  var vis_km = 0.0
  var vis_miles = 0.0
  var uv = 0.0
  var gust_mph = 0.0
  var gust_kph = 0.0
  var displayTemp: String?
}
