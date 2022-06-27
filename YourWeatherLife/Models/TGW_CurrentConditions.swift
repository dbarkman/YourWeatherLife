//
//  CurrentConditions.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/21/22.
//

import Foundation

struct TGW_CurrentConditionsDecoder: Decodable {
  private enum RootCodingKeys: String, CodingKey {
    case location, current
  }
  
  private(set) var location: TGW_Location
  private(set) var current: TGW_Current

  init(from decoder: Decoder) throws {
    let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
    self.location = try rootContainer.decode(TGW_Location.self, forKey: .location)
    self.current = try rootContainer.decode(TGW_Current.self, forKey: .current)
    self.current.displayTemp = Formatters.format(temp: self.current.temp_c, from: .celsius)
  }
}

struct TGW_CurrentConditions: Decodable, Hashable {
  var location: TGW_Location
  var current: TGW_Current
}

struct TGW_Location: Decodable, Hashable {
  var name: String
  var region: String
  var country: String
  var lat: Double
  var lon: Double
  var tz_id: String
  var localtime_epoch: Double
  var localtime: String
}

struct TGW_Current: Decodable, Hashable {
  var temp_c = 0.0
  var temp_f = 0.0
  var is_day = 1
  var condition: TGW_Condition
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

struct TGW_Condition: Decodable, Hashable {
  var text: String
  var icon: String
  var code: Int
}
