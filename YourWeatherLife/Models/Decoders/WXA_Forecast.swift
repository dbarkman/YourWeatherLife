//
//  WXA_Forecast.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/27/22.
//

import Foundation
import OSLog

struct WXA_ForecastDecoder: Decodable {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "WXA_ForecastDecoder")

  private enum RootCodingKeys: String, CodingKey {
    case location, current, forecast
  }
  
  private(set) var wxa_location: WXA_Location
  private(set) var wxa_current: WXA_Current
  private(set) var wxa_forecast: WXA_Forecast
  private(set) var wxa_forecastHours = [WXA_ForecastHours]()
  private(set) var wxa_forecastDays = [WXA_ForecastDays]()
  
  init(from decoder: Decoder) throws {
    let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
    wxa_location = try rootContainer.decode(WXA_Location.self, forKey: .location)
    wxa_current = try rootContainer.decode(WXA_Current.self, forKey: .current)
    wxa_forecast = try rootContainer.decode(WXA_Forecast.self, forKey: .forecast)
    
    for var day in wxa_forecast.forecastday {
      let fd = day.day
      let fdc = fd.condition
      let fa = day.astro
      day.location = wxa_location.name
      day.maxtemp_c = fd.maxtemp_c
      day.maxtemp_f = fd.maxtemp_f
      day.mintemp_c = fd.mintemp_c
      day.mintemp_f = fd.mintemp_f
      day.avgtemp_c = fd.avgtemp_c
      day.avgtemp_f = fd.avgtemp_f
      day.maxwind_mph = fd.maxwind_mph
      day.maxwind_kph = fd.maxwind_kph
      day.totalprecip_mm = fd.totalprecip_mm
      day.totalprecip_in = fd.totalprecip_in
      day.avgvis_km = fd.avgvis_km
      day.avgvis_miles = fd.avgvis_miles
      day.avghumidity = fd.avghumidity
      day.daily_will_it_rain = fd.daily_will_it_rain
      day.daily_chance_of_rain = fd.daily_chance_of_rain
      day.daily_will_it_snow = fd.daily_will_it_snow
      day.daily_chance_of_snow = fd.daily_chance_of_snow
      day.condition_text = fdc.text
      day.condition_icon = fdc.icon
      day.condition_code = fdc.code
      day.uv = fd.uv
      day.sunrise = fa.sunrise
      day.sunset = fa.sunset
      day.moonrise = fa.moonrise
      day.moonset = fa.moonset
      day.moon_phase = fa.moon_phase
      day.moon_illumination = fa.moon_illumination
      wxa_forecastDays.append(day)
      let hours = day.hour
      for var hour in hours {
        let fhc = hour.condition
        hour.location = wxa_location.name
        hour.dateTime = hour.time
        hour.date = hour.time.components(separatedBy: " ").first
        hour.time = (hour.dateTime?.components(separatedBy: " ").last)!
        hour.condition_text = fhc.text
        hour.condition_icon = fhc.icon
        hour.condition_code = fhc.code
        wxa_forecastHours.append(hour)
      }
    }
  }
}

struct WXA_Forecast: Decodable, Hashable {
  var forecastday: [WXA_ForecastDays]
}

struct WXA_ForecastDays: Decodable, Hashable {
  var location: String?
  var date: String
  var date_epoch: Double
  var day: WXA_Day
  var maxtemp_c: Double?
  var maxtemp_f: Double?
  var mintemp_c: Double?
  var mintemp_f: Double?
  var avgtemp_c: Double?
  var avgtemp_f: Double?
  var maxwind_mph: Double?
  var maxwind_kph: Double?
  var totalprecip_mm: Double?
  var totalprecip_in: Double?
  var avgvis_km: Double?
  var avgvis_miles: Double?
  var avghumidity: Double?
  var daily_will_it_rain: Int?
  var daily_chance_of_rain: Int?
  var daily_will_it_snow: Int?
  var daily_chance_of_snow: Int?
  var condition_text: String?
  var condition_icon: String?
  var condition_code: Int?
  var uv: Double?
  var astro: WXA_Astro
  var sunrise: String?
  var sunset: String?
  var moonrise: String?
  var moonset: String?
  var moon_phase: String?
  var moon_illumination: String?
  var hour: [WXA_ForecastHours]
  
  var dictionaryValue: [String: Any] {
    [
      "location": location!,
      "date": date,
      "date_epoch": date_epoch,
      "maxtemp_c": maxtemp_c!,
      "maxtemp_f": maxtemp_f!,
      "mintemp_c": mintemp_c!,
      "mintemp_f": mintemp_f!,
      "avgtemp_c": avgtemp_c!,
      "avgtemp_f": avgtemp_f!,
      "maxwind_mph": maxwind_mph!,
      "maxwind_kph": maxwind_kph!,
      "totalprecip_mm": totalprecip_mm!,
      "totalprecip_in": totalprecip_in!,
      "avgvis_km": avgvis_km!,
      "avgvis_miles": avgvis_miles!,
      "avghumidity": avghumidity!,
      "daily_will_it_rain": daily_will_it_rain!,
      "daily_chance_of_rain": daily_chance_of_rain!,
      "daily_will_it_snow": daily_will_it_snow!,
      "daily_chance_of_snow": daily_chance_of_snow!,
      "condition_text": condition_text!,
      "condition_icon": condition_icon!,
      "condition_code": condition_code!,
      "uv": uv!,
      "sunrise": sunrise!,
      "sunset": sunset!,
      "moonrise": moonrise!,
      "moonset": moonset!,
      "moon_phase": moon_phase!,
      "moon_illumination": moon_illumination!
    ]
  }
}

struct WXA_Day: Decodable, Hashable {
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
  var condition: WXA_Condition
  var uv: Double
}

struct WXA_Astro: Decodable, Hashable {
  var sunrise: String
  var sunset: String
  var moonrise: String
  var moonset: String
  var moon_phase: String
  var moon_illumination: String
}

struct WXA_ForecastHours: Decodable, Hashable {
  var location: String?
  var time_epoch: Double
  var dateTime: String?
  var date: String?
  var time: String
  var temp_c: Double
  var temp_f: Double
  var is_day: Int
  var condition: WXA_Condition
  var condition_text: String?
  var condition_icon: String?
  var condition_code: Int?
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
  
  var dictionaryValue: [String: Any] {
    [
      "location": location!,
      "time_epoch": time_epoch,
      "dateTime": dateTime!,
      "date": date!,
      "time": time,
      "temp_c": temp_c,
      "temp_f": temp_f,
      "is_day": is_day,
      "condition_text": condition_text!,
      "condition_icon": condition_icon!,
      "condition_code": condition_code!,
      "wind_mph": wind_mph,
      "wind_kph": wind_kph,
      "wind_degree": wind_degree,
      "wind_dir": wind_dir,
      "pressure_mb": pressure_mb,
      "pressure_in": pressure_in,
      "precip_mm": precip_mm,
      "precip_in": precip_in,
      "humidity": humidity,
      "cloud": cloud,
      "feelslike_c": feelslike_c,
      "feelslike_f": feelslike_f,
      "windchill_c": windchill_c,
      "windchill_f": windchill_f,
      "heatindex_c": heatindex_c,
      "heatindex_f": heatindex_f,
      "dewpoint_c": dewpoint_c,
      "dewpoint_f": dewpoint_f,
      "will_it_rain": will_it_rain,
      "chance_of_rain": chance_of_rain,
      "will_it_snow": will_it_snow,
      "chance_of_snow": chance_of_snow,
      "vis_km": vis_km,
      "vis_miles": vis_miles,
      "gust_mph": gust_mph,
      "gust_kph": gust_kph,
      "uv": uv
    ]
  }
}
