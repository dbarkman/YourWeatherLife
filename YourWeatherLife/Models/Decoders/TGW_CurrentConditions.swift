//
//  CurrentConditions.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/21/22.
//

import Foundation
import OSLog

struct TGW_CurrentConditionsDecoder: Decodable {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "TGW_CurrentConditionsDecoder")
  
  var container = LocalPersistenceController.shared.container

  private enum RootCodingKeys: String, CodingKey {
    case location, current
  }
  
  private(set) var current: Current
  
  private(set) var tgw_location: TGW_Location
  private(set) var tgw_current: TGW_Current

  init(from decoder: Decoder) throws {
    let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
    self.tgw_location = try rootContainer.decode(TGW_Location.self, forKey: .location)
    self.tgw_current = try rootContainer.decode(TGW_Current.self, forKey: .current)
    
    let temperature = Formatters.shared.format(temp: self.tgw_current.temp_c, from: .celsius)
    let condition = tgw_current.condition.text
    let isDay = Int16(tgw_current.is_day)
    let iconFileName = tgw_current.condition.icon.components(separatedBy: "/").last
    let iconName = iconFileName?.components(separatedBy: ".").first ?? "113"
    let icon = isDay == 1 ? "day/" + iconName : "night/" + iconName
    let location = tgw_location.name
    
    current = Current(temperature: temperature, condition: condition, icon: icon, location: location)
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
  var temp_c: Double
  var temp_f: Double
  var is_day: Int
  var condition: TGW_Condition
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

struct TGW_Condition: Decodable, Hashable {
  var text: String
  var icon: String
  var code: Int
}
