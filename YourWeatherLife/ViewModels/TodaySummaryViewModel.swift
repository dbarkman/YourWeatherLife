//
//  TodaySummaryViewModel.swift
//  YourWeatherLife
//
//  Created by David Barkman on 7/4/22.
//

import SwiftUI
import CoreData
import OSLog

class TodaySummaryViewModel: ObservableObject {

  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "TodaySummaryViewModel")
  
  @Published var summary = Today()
  
  var viewContext = LocalPersistenceController.shared.container.viewContext
  
  init() {
    NotificationCenter.default.addObserver(self, selector: #selector(fetchTodaySummary), name: .forecastInsertedEvent, object: nil)
  }
  
  @objc func fetchTodaySummary() {
    let dateTimeFormatter = DateFormatter()
    dateTimeFormatter.dateFormat = "yyyy-MM-dd"
    let today = dateTimeFormatter.string(from: Date())
    let fetchRequest: NSFetchRequest<TGWForecastDay>
    fetchRequest = TGWForecastDay.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "date = %@", today)
    do {
      let forecastDay = try viewContext.fetch(fetchRequest)
      if forecastDay.count > 0 {
        let todayForecast = forecastDay[0]
        let todaySummary = configureDay(todayForecast: todayForecast)
        DispatchQueue.main.async {
          self.summary = todaySummary.0
        }
      } //end of forecastDay
    } catch {
      logger.debug("Could not fetch forecast for today.")
    }
  }
  
  func configureDay(todayForecast: TGWForecastDay) -> (Today, [TGWForecastHour]) {
//    let todayForecast = forecastDay[0]
    let dayDate = todayForecast.date! + " 00:00"
    print("dbark - \(dayDate)")
    let dayOfWeekDate = Dates.makeDateFromTime(time: dayDate, format: "yyyy-MM-dd HH:mm")
    var precipitation = false
    var precipitationType = ""
    var precipitationPercent = ""
    var precipitaionTotal = 0.0
    if todayForecast.daily_will_it_rain == 1 || todayForecast.daily_will_it_snow == 1 {
      precipitation = true
      precipitaionTotal = todayForecast.totalprecip_mm
      if todayForecast.daily_will_it_rain == 1 {
        precipitationType = "Rain"
        precipitationPercent = "\(todayForecast.daily_chance_of_rain)%"
      }
      if todayForecast.daily_will_it_snow == 1 {
        if !precipitationType.isEmpty {
          precipitationType += " and Snow"
        } else {
          precipitationType = "Snow"
          precipitationPercent = "\(todayForecast.daily_chance_of_snow)%"
        }
      }
    } //precip
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
    let fetchRequest: NSFetchRequest<TGWForecastHour>
    fetchRequest = TGWForecastHour.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TGWForecastHour.time_epoch, ascending: true)]
    fetchRequest.predicate = NSPredicate(format: "date = %@", todayForecast.date!)
    guard let forecastHours = try? viewContext.fetch(fetchRequest) else { return (Today(), []) }
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
    today.precipitation = precipitation
    today.precipitationType = precipitationType
    today.precipitationPercent = precipitationPercent
    today.precipitationTotal = String(Formatters.format(length: precipitaionTotal, from: .millimeters))
    today.coldestTemp = Formatters.format(temp: coldestTemp, from: .celsius)
    today.warmestTemp = Formatters.format(temp: warmestTemps, from: .celsius)
    today.coldestTime = Dates.makeDisplayTimeFromTime(time: coldestTime, format: "HH:mm")
    today.warmestTime = Dates.makeDisplayTimeFromTime(time: warmestTime, format: "HH:mm")
    today.sunriseTemp = Formatters.format(temp: sunriseTemp, from: .celsius)
    today.sunsetTemp = Formatters.format(temp: sunsetTemp, from: .celsius)
    today.sunriseTime = Dates.makeDisplayTimeFromTime(time: sunriseTime!, format: "hh:mm aa")
    today.sunsetTime = Dates.makeDisplayTimeFromTime(time: sunsetTime!, format: "hh:mm aa")
    today.dayOfWeek = Dates.makeStringFromDate(date: dayOfWeekDate, format: "EEE")
    today.displayDate = Dates.makeStringFromDate(date: dayOfWeekDate, format: "EEE, MM/dd")
    today.humidity = String(todayForecast.avghumidity)
    today.averageTemp = String(Formatters.format(temp: todayForecast.avgtemp_c, from: .celsius))
    today.visibility = String(Formatters.format(length: todayForecast.avgvis_km, from: .kilometers))
    today.condition = todayForecast.condition_text ?? ""
    today.conditionIcon = todayForecast.condition_icon ?? ""
    today.wind = String(Formatters.format(speed: todayForecast.maxwind_kph, from: .kilometersPerHour))
    today.moonIllumination = todayForecast.moon_illumination ?? ""
    today.moonPhase = todayForecast.moon_phase ?? ""
    today.moonRiseTime = todayForecast.moonrise ?? ""
    today.moonSetTime = todayForecast.moonset ?? ""
    today.uv = String(todayForecast.uv)
    today.date = Dates.makeStringFromDate(date: dayOfWeekDate, format: "yyyy-MM-dd")
    return (today, forecastHours)
  }
}