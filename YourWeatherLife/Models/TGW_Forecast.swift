//
//  TGW_Forecast.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/27/22.
//

import Foundation
import OSLog

struct TGW_ForecastDecoder: Decodable {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "TGW_Forecast")
  var container = LocalPersistenceController.shared.container
  
  private enum RootCodingKeys: String, CodingKey {
    case location, current, forecast, forecastday
  }
  
  private enum ForecastHourCodingKeys: String, CodingKey {
    case hour
  }
  
  private(set) var tgw_location: TGW_Location
  private(set) var tgw_current: TGW_Current
  private(set) var tgw_forecast: TGW_Forecast
  private(set) var tgw_forecastHours = [TGW_Hour]()
  
  init(from decoder: Decoder) throws {
    let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
    tgw_location = try rootContainer.decode(TGW_Location.self, forKey: .location)
    tgw_current = try rootContainer.decode(TGW_Current.self, forKey: .current)
    tgw_forecast = try rootContainer.decode(TGW_Forecast.self, forKey: .forecast)
    
    let forecastContainer = try rootContainer.nestedContainer(keyedBy: RootCodingKeys.self, forKey: .forecast)
    var forecastDayContainer = try forecastContainer.nestedUnkeyedContainer(forKey: .forecastday)
    while !forecastDayContainer.isAtEnd {
      let forecastHourContainerTop = try forecastDayContainer.nestedContainer(keyedBy: ForecastHourCodingKeys.self)
      var forecastHourContainer = try forecastHourContainerTop.nestedUnkeyedContainer(forKey: .hour)
      while !forecastHourContainer.isAtEnd {
        if let forecastHour = try? forecastHourContainer.decode(TGW_Hour.self) {
          tgw_forecastHours.append(forecastHour)
        }
      }
    }
  }
}

struct TGW_Forecast: Decodable, Hashable {
  var forecastday: [TGW_ForecastDay]
}

struct TGW_ForecastDay: Decodable, Hashable {
  var date: String
  var date_epoch: Double
  var day: TGW_Day
  var astro: TGW_Astro
//  var hour: [TGW_Hour]
}

struct TGW_Day: Decodable, Hashable {
  var maxtemp_c: Double
  var maxtemp_f: Double
  var mintemp_c: Double
  var mintemp_f: Double
  var avgtemp_c: Double
  var avgtemp_f: Double
  var maxwind_mph: Double
  var maxwind_kph: Double
  var totalprecip_mm: Double
  var totalprecip_in: Double
  var avgvis_km: Double
  var avgvis_miles: Double
  var avghumidity: Double
  var daily_will_it_rain: Int
  var daily_chance_of_rain: Int
  var daily_will_it_snow: Int
  var daily_chance_of_snow: Int
  var condition: TGW_Condition
  var uv: Double
}

struct TGW_Astro: Decodable, Hashable {
  var sunrise: String
  var sunset: String
  var moonrise: String
  var moonset: String
  var moon_phase: String
  var moon_illumination: String
}

struct TGW_Hour: Decodable, Hashable {
  var time_epoch: Double
  var time: String
  var temp_c: Double
  var temp_f: Double
  var is_day: Int
  var condition: TGW_Condition
  var wind_mph: Double
  var wind_kph: Double
  var wind_degree: Int
  var wind_dir: String
  var pressure_mb: Double
  var pressure_in: Double
  var precip_mm: Double
  var precip_in: Double
  var humidity: Int
  var cloud: Int
  var feelslike_c: Double
  var feelslike_f: Double
  var windchill_c: Double
  var windchill_f: Double
  var heatindex_c: Double
  var heatindex_f: Double
  var dewpoint_c: Double
  var dewpoint_f: Double
  var will_it_rain: Int
  var chance_of_rain: Int
  var will_it_snow: Int
  var chance_of_snow: Int
  var vis_km: Double
  var vis_miles: Double
  var gust_mph: Double
  var gust_kph: Double
  var uv: Double
}

//struct TGW_CurrentConditions: Decodable, Hashable {
//  var location: TGW_Location
//  var current: TGW_Current
//}

//struct TGW_Location: Decodable, Hashable {
//  var name: String
//  var region: String
//  var country: String
//  var lat: Double
//  var lon: Double
//  var tz_id: String
//  var localtime_epoch: Double
//  var localtime: String
//}

//struct TGW_Current: Decodable, Hashable {
//  var temp_c = 0.0
//  var temp_f = 0.0
//  var is_day = 1
//  var condition: TGW_Condition
//  var wind_mph = 0.0
//  var wind_kph = 0.0
//  var wind_degree = 0.0
//  var wind_dir = "WSW"
//  var pressure_mb = 0.0
//  var pressure_in = 0.0
//  var precip_mm = 0.0
//  var precip_in = 0.0
//  var humidity = 0.0
//  var cloud = 0.0
//  var feelslike_c = 0.0
//  var feelslike_f = 0.0
//  var vis_km = 0.0
//  var vis_miles = 0.0
//  var uv = 0.0
//  var gust_mph = 0.0
//  var gust_kph = 0.0
//  var displayTemp: String?
//}

//struct TGW_Condition: Decodable, Hashable {
//  var text: String
//  var icon: String
//  var code: Int
//}
