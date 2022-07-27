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
  
  static let shared = TodaySummaryViewModel()
  
  private var viewContext = LocalPersistenceController.shared.container.viewContext
  
  @Published var summary = Today()
  
  private init() {
    NotificationCenter.default.addObserver(self, selector: #selector(fetchTodaySummary), name: .forecastInsertedEvent, object: nil)
  }
  
  @objc func fetchTodaySummary() {
    let dateTimeFormatter = DateFormatter()
    dateTimeFormatter.dateFormat = "yyyy-MM-dd"
    let today = dateTimeFormatter.string(from: Date())
    let location = UserDefaults.standard.string(forKey: "currentConditionsLocation") ?? "Kirkland"
    let fetchRequest: NSFetchRequest<TGWForecastDay>
    fetchRequest = TGWForecastDay.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "date = %@ AND location = %@", today, location)
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
      logger.error("Could not fetch forecast for today. 😭 \(error.localizedDescription)")
    }
  }
  
  func configureDay(todayForecast: TGWForecastDay, isToday: Bool = false) -> (Today, [TGWForecastHour]) {
    let dayDate = (todayForecast.date ?? "") + " 00:00"
    let dayOfWeekDate = Dates.shared.makeDateFromString(date: dayDate, format: "yyyy-MM-dd HH:mm")
    let precip = WeekendSummaryViewModel.shared.setPrecipitation(forecastDay: todayForecast)
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
    let fetchRequest: NSFetchRequest<TGWForecastHour>
    fetchRequest = TGWForecastHour.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TGWForecastHour.time_epoch, ascending: true)]
    fetchRequest.predicate = NSPredicate(format: "date = %@ AND location = %@", todayForecast.date ?? "", location)
    var forecastHours: [TGWForecastHour] = []
    do {
      forecastHours = try viewContext.fetch(fetchRequest)
    } catch {
      logger.error("Couldn't fetch TGWForecastHour. 😭 \(error.localizedDescription)")
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
    today.coldestTime = Dates.shared.makeDisplayTimeFromTime(time: coldestTime, format: "HH:mm")
    today.warmestTime = Dates.shared.makeDisplayTimeFromTime(time: warmestTime, format: "HH:mm")
    today.sunriseTemp = Formatters.shared.format(temp: sunriseTemp, from: .celsius)
    today.sunsetTemp = Formatters.shared.format(temp: sunsetTemp, from: .celsius)
    today.sunriseTime = Dates.shared.makeDisplayTimeFromTime(time: sunriseTime ?? "00:00", format: "hh:mm aa")
    today.sunsetTime = Dates.shared.makeDisplayTimeFromTime(time: sunsetTime ?? "00:00", format: "hh:mm aa")
    today.dayOfWeek = isToday ? "Today" : Dates.shared.makeStringFromDate(date: dayOfWeekDate, format: "EEEE")
    today.displayDate = Dates.shared.makeStringFromDate(date: dayOfWeekDate, format: "EEEE, MMMM d")
    today.humidity = String(todayForecast.avghumidity)
    today.averageTemp = String(Formatters.shared.format(temp: todayForecast.avgtemp_c, from: .celsius))
    today.visibility = String(Formatters.shared.format(length: todayForecast.avgvis_km, from: .kilometers))
    today.condition = todayForecast.condition_text ?? ""
    today.conditionIcon = todayForecast.condition_icon ?? ""
    today.wind = String(Formatters.shared.format(speed: todayForecast.maxwind_kph, from: .kilometersPerHour))
    today.moonIllumination = todayForecast.moon_illumination ?? ""
    today.moonPhase = todayForecast.moon_phase ?? ""
    today.moonRiseTime = Dates.shared.makeDisplayTimeFromTime(time: todayForecast.moonrise ?? "00:00", format: "hh:mm aa")
    today.moonSetTime = Dates.shared.makeDisplayTimeFromTime(time: todayForecast.moonset ?? "00:00", format: "hh:mm aa")
    today.uv = String(Int(todayForecast.uv))
    today.date = Dates.shared.makeStringFromDate(date: dayOfWeekDate, format: "yyyy-MM-dd")
    return (today, forecastHours)
  }
}
