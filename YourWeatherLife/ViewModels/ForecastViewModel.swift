//
//  ForecastViewModel.swift
//  YourWeatherLife
//
//  Created by David Barkman on 7/27/22.
//

import Foundation
import CoreData
import OSLog

class ForecastViewModel: ObservableObject {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "ForecastViewModel")
  
  static let shared = ForecastViewModel()
  var globalViewModel = GlobalViewModel.shared

  private var viewContext = LocalPersistenceController.shared.container.viewContext
//  private var viewCloudContext = CloudPersistenceController.shared.container.viewContext
  
  @Published var forecastDays = [Today]()
  @Published var forecastHours = [HourForecast]()

  private init() { }

  func create14DayForecast() {
    let dateTimeFormatter = DateFormatter()
    dateTimeFormatter.dateFormat = "yyyy-MM-dd"
    let today = dateTimeFormatter.string(from: Date())
    let location = UserDefaults.standard.string(forKey: "currentConditionsLocation") ?? "Kirkland"
    let fetchRequest: NSFetchRequest<TGWForecastDay>
    fetchRequest = TGWForecastDay.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "date >= %@ AND location = %@", today, location)
    var forecastDays = [Today]()
    do {
      let forecastDay = try viewContext.fetch(fetchRequest)
      for day in forecastDay {
        let todayResult = globalViewModel.configureDay(todayForecast: day)
        var today = todayResult.0
        let hours = todayResult.1
        var hoursForecast = [HourForecast]()
        for hour in hours {
          hoursForecast.append(globalViewModel.configureHour(hour: hour))
        }
        today.hours = hoursForecast
        forecastDays.append(today)
      }
    } catch {
      logger.error("Couldn't fetch 14 day forecast. 😭 \(error.localizedDescription)")
    }
    DispatchQueue.main.async {
      self.forecastDays = forecastDays
    }
  }
  
  func create336HourForecast() {
    let priorHour = Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date()
    let today = Dates.shared.makeStringFromDate(date: priorHour, format: "yyyy-MM-dd HH:mm")
    let location = UserDefaults.standard.string(forKey: "currentConditionsLocation") ?? "Kirkland"
    let fetchRequest: NSFetchRequest<TGWForecastHour>
    fetchRequest = TGWForecastHour.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TGWForecastHour.time_epoch, ascending: true)]
    fetchRequest.predicate = NSPredicate(format: "dateTime >= %@ AND location = %@", today, location)
    do {
      let forecastHour = try viewContext.fetch(fetchRequest)
      var hours = [HourForecast]()
      for hour in forecastHour {
        hours.append(globalViewModel.configureHour(hour: hour))
      }
      DispatchQueue.main.async {
        self.forecastHours = hours
      }
    } catch {
      logger.error("Couldn't fetch 336 hour forecast. 😭 \(error.localizedDescription)")
    }
  }
}
