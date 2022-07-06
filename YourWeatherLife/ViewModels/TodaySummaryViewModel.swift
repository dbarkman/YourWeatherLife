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
//        var precipitation = false
//        var precipitationType = ""
//        var precipitationPercent = ""
//        if todayForecast.daily_will_it_rain == 1 || todayForecast.daily_will_it_snow == 1 {
//          precipitation = true
//          if todayForecast.daily_will_it_rain == 1 {
//            precipitationType = "Rain"
//            precipitationPercent = "\(todayForecast.daily_chance_of_rain)%"
//          }
//          if todayForecast.daily_will_it_snow == 1 {
//            if !precipitationType.isEmpty {
//              precipitationType += " and Snow"
//            } else {
//              precipitationType = "Snow"
//              precipitationPercent = "\(todayForecast.daily_chance_of_snow)%"
//            }
//          }
//        } //precip
//        var sunriseTemp = 0.0
//        let sunriseTime = todayForecast.sunrise
//        var sunsetTemp = 0.0
//        let sunsetTime = todayForecast.sunset
//        let sunriseHour = sunriseTime?.components(separatedBy: ":").first
//        let sunsetHour = sunsetTime?.components(separatedBy: ":").first
//        var coldestTemp = 999.9
//        var coldestTime = ""
//        var warmestTemps = -999.9
//        var warmestTime = ""
//        let fetchRequest: NSFetchRequest<TGWForecastHour>
//        fetchRequest = TGWForecastHour.fetchRequest()
//        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TGWForecastHour.time_epoch, ascending: true)]
//        fetchRequest.predicate = NSPredicate(format: "date = %@", today)
//        if let forecastHours = try? viewContext.fetch(fetchRequest) {
//          for hour in forecastHours {
//            let time = hour.time?.components(separatedBy: " ").last ?? "00:00"
//            let hourComponent = time.components(separatedBy: ":").first ?? "00"
//            if hour.temp_c > warmestTemps {
//              warmestTemps = hour.temp_c
//              warmestTime = time
//            }
//            if hour.temp_c < coldestTemp {
//              coldestTemp = hour.temp_c
//              coldestTime = time
//            }
//            if sunriseHour == hourComponent {
//              sunriseTemp = hour.temp_c
//            }
//            if sunsetHour == hourComponent {
//              sunsetTemp = hour.temp_c
//            }
//          }
//        } //temps & astro
//        let formattedColdestTemp = Formatters.format(temp: coldestTemp, from: .celsius)
//        let formattedWarmestTemp = Formatters.format(temp: warmestTemps, from: .celsius)
//        let convertedColdestTime = Dates.makeDisplayTimeFromTime(time: coldestTime, format: "HH:mm")
//        let convertedWarmestTime = Dates.makeDisplayTimeFromTime(time: warmestTime, format: "HH:mm")
//        let formattedSunriseTemp = Formatters.format(temp: sunriseTemp, from: .celsius)
//        let formattedSunsetTemp = Formatters.format(temp: sunsetTemp, from: .celsius)
//        let convertedSunriseTime = Dates.makeDisplayTimeFromTime(time: sunriseTime!, format: "hh:mm aa")
//        let convertedSunsetTime = Dates.makeDisplayTimeFromTime(time: sunsetTime!, format: "hh:mm aa")
//        let todaySummaryTemp = Today(precipitation: precipitation, precipitationType: precipitationType, precipitationPercent: precipitationPercent, coldestTemp: formattedColdestTemp, coldestTime: convertedColdestTime, warmestTemp: formattedWarmestTemp, warmestTime: convertedWarmestTime, sunriseTemp: formattedSunriseTemp, sunriseTime: convertedSunriseTime, sunsetTemp: formattedSunsetTemp, sunsetTime: convertedSunsetTime)
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
    if todayForecast.daily_will_it_rain == 1 || todayForecast.daily_will_it_snow == 1 {
      precipitation = true
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
    let formattedColdestTemp = Formatters.format(temp: coldestTemp, from: .celsius)
    let formattedWarmestTemp = Formatters.format(temp: warmestTemps, from: .celsius)
    let convertedColdestTime = Dates.makeDisplayTimeFromTime(time: coldestTime, format: "HH:mm")
    let convertedWarmestTime = Dates.makeDisplayTimeFromTime(time: warmestTime, format: "HH:mm")
    let formattedSunriseTemp = Formatters.format(temp: sunriseTemp, from: .celsius)
    let formattedSunsetTemp = Formatters.format(temp: sunsetTemp, from: .celsius)
    let convertedSunriseTime = Dates.makeDisplayTimeFromTime(time: sunriseTime!, format: "hh:mm aa")
    let convertedSunsetTime = Dates.makeDisplayTimeFromTime(time: sunsetTime!, format: "hh:mm aa")
    let dayOfWeek = Dates.makeStringFromDate(date: dayOfWeekDate, format: "EEEE")
    let todaySummary = Today(precipitation: precipitation, precipitationType: precipitationType, precipitationPercent: precipitationPercent, coldestTemp: formattedColdestTemp, coldestTime: convertedColdestTime, warmestTemp: formattedWarmestTemp, warmestTime: convertedWarmestTime, sunriseTemp: formattedSunriseTemp, sunriseTime: convertedSunriseTime, sunsetTemp: formattedSunsetTemp, sunsetTime: convertedSunsetTime, dayOfWeek: dayOfWeek)
    return (todaySummary, forecastHours)
    
  }
}
