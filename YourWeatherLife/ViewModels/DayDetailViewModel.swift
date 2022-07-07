//
//  DayDetailViewModel.swift
//  YourWeatherLife
//
//  Created by David Barkman on 7/5/22.
//

import Foundation
import CoreData
import OSLog

class DayDetailViewModel: ObservableObject {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "WeekendSummaryViewModel")
  
  @Published var todayArray = [Today]()
  
  var viewContext = LocalPersistenceController.shared.container.viewContext
  
  @objc func fetchDayDetail(dates: [String]) {
    var predicate = ""
    for date in dates {
      predicate.append("'\(date)',")
    }
    let finalPredicate = predicate.dropLast()
    let fetchRequest: NSFetchRequest<TGWForecastDay>
    fetchRequest = TGWForecastDay.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TGWForecastDay.date, ascending: true)]
    fetchRequest.predicate = NSPredicate(format: "date IN {\(finalPredicate)}")
    if let forecastDays = try? viewContext.fetch(fetchRequest) {
      var todayArray = [Today]()
      for day in forecastDays {
        let thisDayResult = TodaySummaryViewModel().configureDay(todayForecast: day)
        var today = thisDayResult.0
        var hours = [HourForecast]()
        for hour in thisDayResult.1 {
          hours.append(configureHour(hour: hour))
        }
        today.hours = hours
        todayArray.append(today)
      }
      DispatchQueue.main.async {
        self.todayArray = todayArray
      }
    }
  }
  
  func configureHour(hour: TGWForecastHour) -> HourForecast {
    var hourForecast = HourForecast()
    hourForecast.temperature = Formatters.format(temp: hour.temp_c, from: .celsius)
    hourForecast.feelsLike = Formatters.format(temp: hour.feelslike_c, from: .celsius)
    hourForecast.heatIndex = Formatters.format(temp: hour.heatindex_c, from: .celsius)
    hourForecast.windChill = Formatters.format(temp: hour.windchill_c, from: .celsius)
    hourForecast.humidity = "\(hour.humidity)"
    hourForecast.dewPoint = Formatters.format(temp: hour.dewpoint_c, from: .celsius)
    hourForecast.willItRain = hour.will_it_rain == 1 ? true : false
    hourForecast.rainChance = "\(hour.chance_of_rain)"
    hourForecast.precipAmount = Formatters.format(length: hour.precip_mm, from: .millimeters)
    hourForecast.willItSnow = hour.will_it_snow == 1 ? true : false
    hourForecast.snowChance = "\(hour.chance_of_snow)"
    hourForecast.wind = Formatters.format(speed: hour.wind_kph, from: .kilometersPerHour)
    hourForecast.windGust = Formatters.format(speed: hour.gust_kph, from: .kilometersPerHour)
    hourForecast.windDirection = "\(getWindDirectionFull(windDirection: hour.wind_dir ?? ""))"
    hourForecast.pressure = Formatters.format(pressure: hour.pressure_mb, from: .millibars)
    hourForecast.visibility = Formatters.format(length: hour.vis_km, from: .kilometers)
    hourForecast.uv = "\(Int(hour.uv))"
    hourForecast.condition = "\(hour.condition_text ?? "")"
    hourForecast.conditionIcon = "\(hour.condition_icon ?? "")"
    hourForecast.time = Dates.makeDisplayTimeFromTime(time: hour.time ?? "00:00", format: "HH:mm")
    hourForecast.timeFull = Dates.makeDisplayTimeFromTime(time: hour.time ?? "00:00", format: "HH:mm", full: true)
    hourForecast.date = "\(hour.date ?? "")"
    let hourDate = Dates.makeDateFromTime(time: hour.date! + " " + hour.time!, format: "yyyy-MM-dd HH:mm")
    hourForecast.displayDate = Dates.makeStringFromDate(date: hourDate, format: "EEE, M/d, h a")
    hourForecast.dayOfWeek = Dates.makeStringFromDate(date: hourDate, format: "EEEE")
    return hourForecast
  }
  
  func getWindDirectionFull(windDirection: String) -> String {
    switch windDirection {
      case "N":
        return "North"
      case "E":
        return "East"
      case "S":
        return "South"
      case "W":
        return "West"
      case "NW":
        return "Northwest"
      case "SW":
        return "Southwest"
      case "NE":
        return "Northeast"
      case "SE":
        return "Southeast"
      case "NNE":
        return "North-Northeast"
      case "NNW":
        return "North-Northwest"
      case "SSE":
        return "South-Southeast"
      case "SSW":
        return "South-Southwest"
      case "WNW":
        return "West-Northwest"
      case "WSW":
        return "West-Southwest"
      case "ENE":
        return "East-Northeast"
      case "ESE":
        return "East-Southeast"
      default:
        return ""
    }
  }
}
