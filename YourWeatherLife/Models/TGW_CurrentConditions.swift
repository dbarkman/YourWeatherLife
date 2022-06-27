//
//  CurrentConditions.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/21/22.
//

import Foundation
import OSLog

struct TGW_CurrentConditionsDecoder: Decodable {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "AOWM_CurrentConditions")
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
    
    let temperature = Formatters.format(temp: self.tgw_current.temp_c, from: .celsius)
    let condition = tgw_current.condition.text
    let isDay = Int16(tgw_current.is_day)
    let iconFileName = tgw_current.condition.icon.components(separatedBy: "/").last
    let iconName = iconFileName?.components(separatedBy: ".").first ?? "113"
    let icon = isDay == 1 ? "day/" + iconName : "night/" + iconName
    let location = tgw_location.name
    
    current = Current(temperature: temperature, condition: condition, icon: icon, location: location)

//    let request = Current.fetchRequest()
//    let current = try container.viewContext.fetch(request)
//    logger.debug("Current count: \(current.count)")
//    if current.count == 0 {
//      let currentObject = Current(context: container.viewContext)
//      currentObject.temperature = Formatters.format(temp: self.tgw_current.temp_c, from: .celsius)
//      currentObject.condition = self.tgw_current.condition.text
//      currentObject.isDay = isDay
//      currentObject.icon = isDay == 1 ? "day/" + icon : "night/" + icon
//      currentObject.dateUpdated = Date()
//      do {
//        try container.viewContext.save()
//      } catch {
//        logger.error("Couldn't save current conditions. 💾")
//      }
//    }
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
