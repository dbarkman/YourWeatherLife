//
//  GlobalViewModel.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/11/22.
//

import Foundation
import CoreData
import Mixpanel
import OSLog

class GlobalViewModel: ObservableObject {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "GlobalViewModel")
  
  static let shared = GlobalViewModel()

  private var viewContext = LocalPersistenceController.shared.container.viewContext
  
  @Published var returningFromChildView = false
  @Published var today = Dates.shared.getTodayDateString(format: "yyyy-MM-dd")
  @Published var weekend = Dates.shared.getThisWeekendDateStrings(format: "yyyy-MM-dd")
  @Published var networkOnline = true {
    didSet {
      guard oldValue != networkOnline else { return }
      if networkOnline {
        logger.debug("Network online now!")
        NotificationCenter.default.post(name: .locationUpdatedEvent, object: nil)
      } else {
        Mixpanel.mainInstance().track(event: "Network Offline")
      }
    }
  }
  
  private init() {
    checkInternetConnection(closure: { connected in
      DispatchQueue.main.async {
        self.networkOnline = connected
      }
    })

    if !UserDefaults.standard.bool(forKey: "automaticLocation") {
      guard let _ = UserDefaults.standard.string(forKey: "manualLocationData") else {
        let authorizationStatus = LocationViewModel.shared.authorizationStatus
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
          UserDefaults.standard.set(true, forKey: "automaticLocation")
        } else {
          UserDefaults.standard.set(false, forKey: "automaticLocation")
          UserDefaults.standard.set("98034", forKey: "manualLocationData")
        }
        return
      }
    }
  }
  
  func configureHour(hour: ForecastHour) -> HourForecast {
    var hourForecast = HourForecast()
    hourForecast.temperature = Formatters.shared.format(temp: hour.temp_c, from: .celsius)
    hourForecast.feelsLike = Formatters.shared.format(temp: hour.feelslike_c, from: .celsius)
    hourForecast.heatIndex = Formatters.shared.format(temp: hour.heatindex_c, from: .celsius)
    hourForecast.windChill = Formatters.shared.format(temp: hour.windchill_c, from: .celsius)
    hourForecast.humidity = "\(hour.humidity)"
    hourForecast.dewPoint = Formatters.shared.format(temp: hour.dewpoint_c, from: .celsius)
    hourForecast.willItRain = hour.will_it_rain == 1 ? true : false
    hourForecast.rainChance = "\(hour.chance_of_rain)"
    hourForecast.precipAmount = Formatters.shared.format(length: hour.precip_mm, from: .millimeters, natural: true)
    hourForecast.willItSnow = hour.will_it_snow == 1 ? true : false
    hourForecast.snowChance = "\(hour.chance_of_snow)"
    hourForecast.wind = Formatters.shared.format(speed: hour.wind_kph, from: .kilometersPerHour)
    hourForecast.windGust = Formatters.shared.format(speed: hour.gust_kph, from: .kilometersPerHour)
    hourForecast.windDirection = "\(getWindDirectionFull(windDirection: hour.wind_dir ?? ""))"
    hourForecast.pressure = Formatters.shared.format(pressure: hour.pressure_mb, from: .millibars)
    hourForecast.visibility = Formatters.shared.format(length: hour.vis_km, from: .kilometers)
    hourForecast.uv = "\(Int(hour.uv))"
    hourForecast.condition = "\(hour.condition_text ?? "")"
    hourForecast.conditionIcon = "\(hour.condition_icon ?? "")"
    hourForecast.time = Dates.shared.makeDisplayTimeFromTime(time: hour.time ?? "00:00", format: "HH:mm", full: true)
    hourForecast.timeFull = Dates.shared.makeDisplayTimeFromTime(time: hour.time ?? "00:00", format: "HH:mm", full: true)
    hourForecast.date = "\(hour.date ?? "")"
    if let dateTime = hour.dateTime {
      let hourDate = Dates.shared.makeDateFromString(date: dateTime, format: "yyyy-MM-dd HH:mm")
      let monthDayFormat = Dates.shared.userFormatDayFirst() ? "d/M" : "M/d"
      hourForecast.displayDate = Dates.shared.makeStringFromDate(date: hourDate, format: "EEEE, \(monthDayFormat), h:mm a")
      hourForecast.shortDisplayDate = Dates.shared.makeStringFromDate(date: hourDate, format: "EEE, \(monthDayFormat), h:mm a")
      hourForecast.dayOfWeek = Dates.shared.makeStringFromDate(date: hourDate, format: "EEEE")
    }
    return hourForecast
  }
  
  func configureDay(todayForecast: ForecastDay, isToday: Bool = false) -> (Today, [ForecastHour]) {
    let dayDate = (todayForecast.date ?? "") + " 00:00"
    let dayOfWeekDate = Dates.shared.makeDateFromString(date: dayDate, format: "yyyy-MM-dd HH:mm")
    let precip = setPrecipitation(forecastDay: todayForecast)
    var sunriseTemp = 0.0
    let sunriseTime = todayForecast.sunrise
    var sunsetTemp = 0.0
    let sunsetTime = todayForecast.sunset
    let sunriseHour = sunriseTime?.components(separatedBy: ":").first
    let sunsetHour = sunsetTime?.components(separatedBy: ":").first
    var coldestTemp = 999.9
    var coldestTime = ""
    var warmestTemps = -999.9
    var warmestTime = ""
    let location = UserDefaults.standard.string(forKey: "currentConditionsLocation") ?? "Kirkland"
    let fetchRequest: NSFetchRequest<ForecastHour>
    fetchRequest = ForecastHour.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ForecastHour.time_epoch, ascending: true)]
    fetchRequest.predicate = NSPredicate(format: "date = %@ AND location = %@", todayForecast.date ?? "", location)
    var forecastHours: [ForecastHour] = []
    do {
      forecastHours = try viewContext.fetch(fetchRequest)
    } catch {
      logger.error("Couldn't fetch ForecastHour. 😭 \(error.localizedDescription)")
      return (Today(), [])
    }
    for hour in forecastHours {
      let time = hour.time?.components(separatedBy: " ").last ?? "00:00"
      let hourComponent = time.components(separatedBy: ":").first ?? "00"
      if hour.temp_c > warmestTemps {
        warmestTemps = hour.temp_c
        warmestTime = time
      }
      if hour.temp_c < coldestTemp {
        coldestTemp = hour.temp_c
        coldestTime = time
      }
      if sunriseHour == hourComponent {
        sunriseTemp = hour.temp_c
      }
      if sunsetHour == hourComponent {
        sunsetTemp = hour.temp_c
      }
    }
    var today = Today()
    today.precipitation = precip.0 //precipitation
    today.precipitationType = precip.1 //precipitationType
    today.precipitationPercent = precip.2 //precipitationPercent
    today.precipitationTotal = String(Formatters.shared.format(length: precip.3, from: .millimeters))
    today.coldestTemp = Formatters.shared.format(temp: coldestTemp, from: .celsius)
    today.warmestTemp = Formatters.shared.format(temp: warmestTemps, from: .celsius)
    today.coldestTime = Dates.shared.makeDisplayTimeFromTime(time: coldestTime, format: "HH:mm", full: true)
    today.warmestTime = Dates.shared.makeDisplayTimeFromTime(time: warmestTime, format: "HH:mm", full: true)
    today.sunriseTemp = Formatters.shared.format(temp: sunriseTemp, from: .celsius)
    today.sunsetTemp = Formatters.shared.format(temp: sunsetTemp, from: .celsius)
    today.sunriseTime = Dates.shared.makeDisplayTimeFromTime(time: sunriseTime ?? "00:00", format: "hh:mm aa", full: true)
    today.sunsetTime = Dates.shared.makeDisplayTimeFromTime(time: sunsetTime ?? "00:00", format: "hh:mm aa", full: true)
    today.dayOfWeek = isToday ? "Today" : Dates.shared.makeStringFromDate(date: dayOfWeekDate, format: "EEEE")
    let monthDayFormat = Dates.shared.userFormatDayFirst() ? "d MMMM" : "MMMM d"
    today.displayDate = Dates.shared.makeStringFromDate(date: dayOfWeekDate, format: "EEEE, \(monthDayFormat)")
    today.humidity = String(Int(todayForecast.avghumidity))
    today.averageTemp = String(Formatters.shared.format(temp: todayForecast.avgtemp_c, from: .celsius))
    today.visibility = String(Formatters.shared.format(length: todayForecast.avgvis_km, from: .kilometers))
    today.condition = todayForecast.condition_text ?? ""
    today.conditionIcon = todayForecast.condition_icon ?? ""
    today.wind = String(Formatters.shared.format(speed: todayForecast.maxwind_kph, from: .kilometersPerHour))
    today.moonIllumination = todayForecast.moon_illumination ?? ""
    today.moonPhase = todayForecast.moon_phase ?? ""
    today.moonRiseTime = Dates.shared.makeDisplayTimeFromTime(time: todayForecast.moonrise ?? "00:00", format: "hh:mm aa", full: true)
    today.moonSetTime = Dates.shared.makeDisplayTimeFromTime(time: todayForecast.moonset ?? "00:00", format: "hh:mm aa", full: true)
    today.uv = String(Int(todayForecast.uv))
    today.date = Dates.shared.makeStringFromDate(date: dayOfWeekDate, format: "yyyy-MM-dd")
    return (today, forecastHours)
  }
  
  func setPrecipitation(forecastDay: ForecastDay) -> (Bool, String, String, Double) {
    var precipitation = false
    var precipitationType = ""
    var precipitationPercent = ""
    var precipitaionTotal = 0.0
    if forecastDay.daily_will_it_rain == 1 || forecastDay.daily_will_it_snow == 1 {
      precipitation = true
      precipitaionTotal = forecastDay.totalprecip_mm
      if forecastDay.daily_will_it_rain == 1 {
        precipitationType = "Rain"
        precipitationPercent = "\(forecastDay.daily_chance_of_rain)%"
      }
      if forecastDay.daily_will_it_snow == 1 {
        if !precipitationType.isEmpty {
          precipitationType += " and Snow"
        } else {
          precipitationType = "Snow"
          precipitationPercent = "\(forecastDay.daily_chance_of_snow)%"
        }
      }
    } //precip
    return (precipitation, precipitationType, precipitationPercent, precipitaionTotal)
  }

  private func getWindDirectionFull(windDirection: String) -> String {
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

  func checkInternetConnection(closure: @escaping (Bool) -> Void) {
    let urlString = "https://weather.solutions/test.html"
    logger.debug("url 3: \(urlString)")
    if let url = URL(string: urlString) {
      var request = URLRequest(url: url)
      request.httpMethod = "HEAD"
      request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
      request.timeoutInterval = 3
      let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
        closure(error == nil)
      })
      task.resume()
    } else {
      closure(false)
    }
  }
  
  func fetchAppVersionNumber() -> String {
    var appVersion = ""
    if let buildNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
      appVersion = buildNumber
    }
    return appVersion
  }
  
  func fetchBuildNumber() -> String {
    var buildNum = ""
    if let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
      buildNum = buildNumber
    }
    return buildNum
  }
}
