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
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "DayDetailViewModel")
  
  static let shared = DayDetailViewModel()
  var globalViewModel = GlobalViewModel.shared

  private var viewContext = LocalPersistenceController.shared.container.viewContext
  
  @Published var todayArray = [Today]()

  private init() { }
  
  func fetchDayDetail(dates: [String], isToday: Bool = false) {
    let location = UserDefaults.standard.string(forKey: "currentConditionsLocation") ?? "Kirkland"
    var predicate = ""
    for date in dates {
      predicate.append("'\(date)',")
    }
    let finalPredicate = predicate.dropLast()
    let fetchRequest: NSFetchRequest<ForecastDay>
    fetchRequest = ForecastDay.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ForecastDay.date, ascending: true)]
    fetchRequest.predicate = NSPredicate(format: "date IN {\(finalPredicate)} AND location = %@", location)
    var forecastDays: [ForecastDay] = []
    do {
      forecastDays = try viewContext.fetch(fetchRequest)
    } catch {
      logger.error("Couldn't fetch ForecastDay. 😭 \(error.localizedDescription)")
    }
    var todayArray = [Today]()
    for day in forecastDays {
      let thisDayResult = globalViewModel.configureDay(todayForecast: day, isToday: isToday)
      var today = thisDayResult.0
      var hours = [HourForecast]()
      for hour in thisDayResult.1 {
        hours.append(globalViewModel.configureHour(hour: hour))
      }
      today.hours = hours
      todayArray.append(today)
    }
    NotificationCenter.default.post(name: .dayDetailViewModelPublished, object: nil)
    DispatchQueue.main.async {
      self.todayArray = todayArray
    }
  }
}
