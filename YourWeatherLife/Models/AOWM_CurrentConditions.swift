//
//  AOWM_CurrentConditions.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/25/22.
//

import Foundation
import OSLog

struct AOWM_CurrentConditionsDecoder: Decodable {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "AOWM_CurrentConditions")

  private enum RootCodingKeys: String, CodingKey {
    case weather, main, visibility, wind, rain, snow, clouds, dt, sys, timezone, id, name
  }
  
  private(set) var aowm_weatherList = [AOWM_Weather]()
  private(set) var aowm_main: AOWM_Main
  private(set) var aowm_currentVisibility: Int
  private(set) var aowm_wind: AOWM_Wind
  private(set) var aowm_rain: AOWM_Rain?
  private(set) var aowm_snow: AOWM_Snow?
  private(set) var aowm_clouds: AOWM_Clouds
  private(set) var aowm_currentObservationDateTime: Int
  private(set) var aowm_sys: AOWM_Sys
  private(set) var aowm_currentTimezoneOffsetSeconds: Int
  private(set) var aowm_currentCityId: Int
  private(set) var aowm_currentCityName: String

  init(from decoder: Decoder) throws {
    let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
    var aowm_weatherContainer = try rootContainer.nestedUnkeyedContainer(forKey: .weather)
    while !aowm_weatherContainer.isAtEnd {
      if let aowm_weather = try? aowm_weatherContainer.decode(AOWM_Weather.self) {
        aowm_weatherList.append(aowm_weather)
      }
    }
    self.aowm_main = try rootContainer.decode(AOWM_Main.self, forKey: .main)
    self.aowm_currentVisibility = try rootContainer.decode(Int.self, forKey: .visibility)
    self.aowm_wind = try rootContainer.decode(AOWM_Wind.self, forKey: .wind)
    do {
      self.aowm_rain = try rootContainer.decode(AOWM_Rain.self, forKey: .rain)
    } catch {
      logger.debug("No rain in current conditions. 🌧")
    }
    do {
      self.aowm_snow = try rootContainer.decode(AOWM_Snow.self, forKey: .snow)
    } catch {
      logger.debug("No snow in current conditions. 🌨")
    }
    self.aowm_clouds = try rootContainer.decode(AOWM_Clouds.self, forKey: .clouds)
    self.aowm_currentObservationDateTime = try rootContainer.decode(Int.self, forKey: .dt)
    self.aowm_sys = try rootContainer.decode(AOWM_Sys.self, forKey: .sys)
    self.aowm_currentTimezoneOffsetSeconds = try rootContainer.decode(Int.self, forKey: .timezone)
    self.aowm_currentCityId = try rootContainer.decode(Int.self, forKey: .id)
    self.aowm_currentCityName = try rootContainer.decode(String.self, forKey: .name)
//    self.current.displayTemp = Formatters.format(temp: self.aowm_main.aowm_mainTemp, from: .celsius)
  }
}

struct AOWM_CurrentConditions: Decodable, Hashable {
  var aowm_weatherList: [AOWM_Weather]
  var aowm_main: AOWM_Main
  var aowm_currentVisibility: Int
  var aowm_wind: AOWM_Wind
  var aowm_rain: AOWM_Rain?
  var aowm_snow: AOWM_Snow?
  var aowm_clouds: AOWM_Clouds
  var aowm_currentObservationDateTime: Int
  var aowm_sys: AOWM_Sys
  var aowm_currentTimezoneOffsetSeconds: Int
  var aowm_currentCityId: Int
  var aowm_currentCityName: String

  enum CodingKeys: String, CodingKey {
    case aowm_weatherList = "weather"
    case aowm_main = "main"
    case aowm_currentVisibility = "visibility"
    case aowm_wind = "wind"
    case aowm_rain = "rain"
    case aowm_snow = "snow"
    case aowm_clouds = "clouds"
    case aowm_currentObservationDateTime = "dt"
    case aowm_sys = "sys"
    case aowm_currentTimezoneOffsetSeconds = "timezone"
    case aowm_currentCityId = "id"
    case aowm_currentCityName = "name"
  }
}

struct AOWM_Weather: Decodable, Hashable {
  var aowm_weatherId: Int
  var aowm_weatherMain: String
  var aowm_weatherDescription: String
  var aowm_weatherIcon: String
  
  enum CodingKeys: String, CodingKey {
    case aowm_weatherId = "id"
    case aowm_weatherMain = "main"
    case aowm_weatherDescription = "description"
    case aowm_weatherIcon = "icon"
  }
}

struct AOWM_Main: Decodable, Hashable {
  var aowm_mainTemp: Double
  var aowm_mainFeelsLike: Double
  var aowm_mainTempMin: Double
  var aowm_mainTempMax: Double
  var aowm_mainPressure: Int
  var aowm_mainHumidity: Int
  var aowm_mainSeaLevelPressure: Int?
  var aowm_mainGroundLevelPressure: Int?

  enum CodingKeys: String, CodingKey {
    case aowm_mainTemp = "temp"
    case aowm_mainFeelsLike = "feels_like"
    case aowm_mainTempMin = "temp_min"
    case aowm_mainTempMax = "temp_max"
    case aowm_mainPressure = "pressure"
    case aowm_mainHumidity = "humidity"
    case aowm_mainSeaLevelPressure = "sea_level"
    case aowm_mainGroundLevelPressure = "grnd_level"
  }
}

struct AOWM_Wind: Decodable, Hashable {
  var aowm_windSpeed: Double
  var aowm_windDegree: Int
  var aowm_windGust: Double?

  enum CodingKeys: String, CodingKey {
    case aowm_windSpeed = "speed"
    case aowm_windDegree = "deg"
    case aowm_windGust = "gust"
  }
}

struct AOWM_Clouds: Decodable, Hashable {
  var aowm_cloudsAll: Int

  enum CodingKeys: String, CodingKey {
    case aowm_cloudsAll = "all"
  }
}

struct AOWM_Rain: Decodable, Hashable {
  var aowm_rain1h: Double?
  var aowm_rain3h: Double?

  enum CodingKeys: String, CodingKey {
    case aowm_rain1h = "1h"
    case aowm_rain3h = "3h"
  }
}

struct AOWM_Snow: Decodable, Hashable {
  var aowm_snow1h: Double?
  var aowm_snow3h: Double?

  enum CodingKeys: String, CodingKey {
    case aowm_snow1h = "1h"
    case aowm_snow3h = "3h"
  }
}

struct AOWM_Sys: Decodable, Hashable {
  var aowm_sysType: Int
  var aowm_sysId: Int
  var aowm_sysCountry: String
  var aowm_sysSunrise: Int
  var aowm_sysSunset: Int

  enum CodingKeys: String, CodingKey {
    case aowm_sysType = "type"
    case aowm_sysId = "id"
    case aowm_sysCountry = "country"
    case aowm_sysSunrise = "sunrise"
    case aowm_sysSunset = "sunset"
  }
}
