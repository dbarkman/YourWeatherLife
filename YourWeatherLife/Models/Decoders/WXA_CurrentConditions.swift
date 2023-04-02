//
//  CurrentConditions.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/21/22.
//

import Foundation
import OSLog

struct WXA_CurrentConditionsDecoder: Decodable {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "WXA_CurrentConditionsDecoder")
  
  var container = LocalPersistenceController.shared.container

  private enum RootCodingKeys: String, CodingKey {
    case location, current
  }
  
  private(set) var current: Current
  
  private(set) var wxa_location: WXA_Location
  private(set) var wxa_current: WXA_Current

  init(from decoder: Decoder) throws {
    let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
    self.wxa_location = try rootContainer.decode(WXA_Location.self, forKey: .location)
    self.wxa_current = try rootContainer.decode(WXA_Current.self, forKey: .current)
    
    let temperature = Formatters.shared.format(temp: self.wxa_current.temp_c, from: .celsius)
    let condition = wxa_current.condition.text
    let isDay = Int16(wxa_current.is_day)
    let iconFileName = wxa_current.condition.icon.components(separatedBy: "/").last
    let iconName = iconFileName?.components(separatedBy: ".").first ?? "113"
    let icon = isDay == 1 ? "day/" + iconName : "night/" + iconName
    let location = wxa_location.name
    
    current = Current(temperature: temperature, condition: condition, icon: icon, location: location)
  }
}

struct WXA_CurrentConditions: Decodable, Hashable {
  var location: WXA_Location
  var current: WXA_Current
}

struct WXA_Location: Decodable, Hashable {
  var name: String
  var region: String
  var country: String
  var lat: Double
  var lon: Double
  var tz_id: String
  var localtime_epoch: Double
  var localtime: String
}

struct WXA_Current: Decodable, Hashable {
  var temp_c: Double
  var temp_f: Double
  var is_day: Int
  var condition: WXA_Condition
  var wind_mph: Double
  var wind_kph: Double
  var wind_degree: Double
  var wind_dir: String
  var pressure_mb: Double
  var pressure_in: Double
  var precip_mm: Double
  var precip_in: Double
  var humidity: Double
  var cloud: Double
  var feelslike_c: Double
  var feelslike_f: Double
  var vis_km: Double
  var vis_miles: Double
  var uv: Double
  var gust_mph: Double
  var gust_kph: Double
  var displayTemp: String?
}

struct WXA_Condition: Decodable, Hashable {
  var text: String
  var icon: String
  var code: Int
}
