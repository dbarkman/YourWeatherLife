//
//  SummaryViewModel.swift
//  YourWeatherLife
//
//  Created by David Barkman on 7/4/22.
//

import SwiftUI
import CoreData
import OSLog

class SummaryViewModel: ObservableObject {

  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "SummaryViewModel")
  
  static let shared = SummaryViewModel()
  var globalViewModel = GlobalViewModel.shared

  private var viewContext = LocalPersistenceController.shared.container.viewContext
  
  @Published var todaySummary = Today()
  @Published var weekendSummary = Weekend()

  private init() {
    NotificationCenter.default.addObserver(self, selector: #selector(fetchSummaries), name: .forecastInsertedEvent, object: nil)
  }
  
  @objc func fetchSummaries() {
    fetchTodaySummary()
    fetchWeekendSummary()
  }
  
  func fetchTodaySummary() {
    let dateTimeFormatter = DateFormatter()
    dateTimeFormatter.dateFormat = "yyyy-MM-dd"
    let today = dateTimeFormatter.string(from: Date())
    let location = UserDefaults.standard.string(forKey: "currentConditionsLocation") ?? "Kirkland"
    let fetchRequest: NSFetchRequest<ForecastDay>
    fetchRequest = ForecastDay.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "date = %@ AND location = %@", today, location)
    do {
      let forecastDay = try viewContext.fetch(fetchRequest)
      if forecastDay.count > 0 {
        let todayForecast = forecastDay[0]
        let todaySummary = globalViewModel.configureDay(todayForecast: todayForecast)
        DispatchQueue.main.async {
          self.todaySummary = todaySummary.0
        }
      } //end of forecastDay
    } catch {
      logger.error("Could not fetch forecast for today. 😭 \(error.localizedDescription)")
    }
  }
  
  func fetchWeekendSummary() {
    let saturdayDate = Calendar.current.nextWeekend(startingAfter: Date())?.start ?? Date()
    let sundayDate = Calendar.current.date(byAdding: .day, value: 1, to: saturdayDate) ?? Date()
    let saturday = Dates.shared.makeStringFromDate(date: saturdayDate, format: "yyyy-MM-dd")
    let sunday = Dates.shared.makeStringFromDate(date: sundayDate, format: "yyyy-MM-dd")
    let location = UserDefaults.standard.string(forKey: "currentConditionsLocation") ?? "Kirkland"
    let fetchRequest: NSFetchRequest<ForecastDay>
    fetchRequest = ForecastDay.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ForecastDay.date, ascending: true)]
    fetchRequest.predicate = NSPredicate(format: "date IN {'\(saturday)', '\(sunday)'} AND location = %@", location)
    var forecastDays: [ForecastDay] = []
    do {
      forecastDays = try viewContext.fetch(fetchRequest)
    } catch {
      logger.error("Couldn't fetch ForecastDay. 😭 \(error.localizedDescription)")
    }
    if forecastDays.count > 1 {
      let saturdayLow = forecastDays[0].mintemp_c
      let saturdayHigh = forecastDays[0].maxtemp_c
      let sundayLow = forecastDays[1].mintemp_c
      let sundayHigh = forecastDays[1].maxtemp_c
      let saturdayPrecipitationResult = globalViewModel.setPrecipitation(forecastDay: forecastDays[0])
      let sundayPrecipitationResult = globalViewModel.setPrecipitation(forecastDay: forecastDays[1])
      
      DispatchQueue.main.async {
        self.weekendSummary.saturdayLow = Formatters.shared.format(temp: saturdayLow, from: .celsius)
        self.weekendSummary.saturdayHigh = Formatters.shared.format(temp: saturdayHigh, from: .celsius)
        self.weekendSummary.saturdayCondition = forecastDays[0].condition_text ?? ""
        self.weekendSummary.sundayLow = Formatters.shared.format(temp: sundayLow, from: .celsius)
        self.weekendSummary.sundayHigh = Formatters.shared.format(temp: sundayHigh, from: .celsius)
        self.weekendSummary.sundayCondition = forecastDays[1].condition_text ?? ""
        self.weekendSummary.saturdayPrecipitation = saturdayPrecipitationResult.0
        self.weekendSummary.saturdayPrecipitationType = saturdayPrecipitationResult.1
        self.weekendSummary.saturdayPrecipitationPercent = saturdayPrecipitationResult.2
        self.weekendSummary.sundayPrecipitation = sundayPrecipitationResult.0
        self.weekendSummary.sundayPrecipitationType = sundayPrecipitationResult.1
        self.weekendSummary.sundayPrecipitationPercent = sundayPrecipitationResult.2
      }
    }
  }
}
