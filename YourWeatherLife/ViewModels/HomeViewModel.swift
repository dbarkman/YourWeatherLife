//
//  HomeViewModel.swift
//  YourWeatherLife
//
//  Created by David Barkman on 7/6/22.
//

import Foundation
import CoreData
import OSLog

class HomeViewModel: ObservableObject {

  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "HomeViewModel")
  
  var viewContext = LocalPersistenceController.shared.container.viewContext
  
  @Published var forecastDays = [Today]()
  @Published var forecastHours = [HourForecast]()

  func create14DayForecast() {
    let dateTimeFormatter = DateFormatter()
    dateTimeFormatter.dateFormat = "yyyy-MM-dd"
    let today = dateTimeFormatter.string(from: Date())
    let fetchRequest: NSFetchRequest<TGWForecastDay>
    fetchRequest = TGWForecastDay.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "date >= %@", today)
    do {
      let forecastDay = try viewContext.fetch(fetchRequest)
      var forecastDays = [Today]()
      for day in forecastDay {
        let todayResult = TodaySummaryViewModel().configureDay(todayForecast: day)
        var today = todayResult.0
        let hours = todayResult.1
        var hoursForecast = [HourForecast]()
        for hour in hours {
          hoursForecast.append(DayDetailViewModel().configureHour(hour: hour))
        }
        today.hours = hoursForecast
        forecastDays.append(today)
      }
      DispatchQueue.main.async {
        self.forecastDays = forecastDays
      }
    } catch {
      logger.debug("Couldn't fetch 14 day forecast. 😭")
    }
  }
  
  func create336HourForecast() {
    let dateTimeFormatter = DateFormatter()
    dateTimeFormatter.dateFormat = "yyyy-MM-dd"
    let today = dateTimeFormatter.string(from: Date())
    let fetchRequest: NSFetchRequest<TGWForecastHour>
    fetchRequest = TGWForecastHour.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TGWForecastHour.time_epoch, ascending: true)]
    fetchRequest.predicate = NSPredicate(format: "date >= %@", today)
    do {
      let forecastHour = try viewContext.fetch(fetchRequest)
      var hours = [HourForecast]()
      for hour in forecastHour {
        hours.append(DayDetailViewModel().configureHour(hour: hour))
      }
      DispatchQueue.main.async {
        self.forecastHours = hours
      }
    } catch {
      logger.debug("Couldn't fetch 336 hour forecast. 😭")
    }
  }

}
