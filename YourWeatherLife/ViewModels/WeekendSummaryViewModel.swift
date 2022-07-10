//
//  WeekendSummaryViewModel.swift
//  YourWeatherLife
//
//  Created by David Barkman on 7/5/22.
//

import Foundation
import CoreData
import OSLog

class WeekendSummaryViewModel: ObservableObject {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "WeekendSummaryViewModel")
  
  @Published var summary = Weekend()
  
  var viewContext = LocalPersistenceController.shared.container.viewContext
  
  init() {
    NotificationCenter.default.addObserver(self, selector: #selector(fetchWeekendSummary), name: .forecastInsertedEvent, object: nil)
  }
  
  @objc func fetchWeekendSummary() {
    let saturdayDate = Calendar.current.nextWeekend(startingAfter: Date())?.start ?? Date()
    let sundayDate = Calendar.current.date(byAdding: .day, value: 1, to: saturdayDate) ?? Date()
    let saturday = Dates.makeStringFromDate(date: saturdayDate, format: "yyyy-MM-dd")
    let sunday = Dates.makeStringFromDate(date: sundayDate, format: "yyyy-MM-dd")
    let fetchRequest: NSFetchRequest<TGWForecastDay>
    fetchRequest = TGWForecastDay.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TGWForecastDay.date, ascending: true)]
    fetchRequest.predicate = NSPredicate(format: "date IN {'\(saturday)', '\(sunday)'}")
    var forecastDays: [TGWForecastDay] = []
    do {
      forecastDays = try viewContext.fetch(fetchRequest)
    } catch {
      logger.error("Couldn't fetch TGWForecastDay. 😭 \(error.localizedDescription)")
    }
    if forecastDays.count > 1 {
      let saturdayLow = forecastDays[0].mintemp_c
      let saturdayHigh = forecastDays[0].maxtemp_c
      let sundayLow = forecastDays[1].mintemp_c
      let sundayHigh = forecastDays[1].maxtemp_c
      let saturdayPrecipitationResult = setPrecipitation(forecastDay: forecastDays[0])
      let sundayPrecipitationResult = setPrecipitation(forecastDay: forecastDays[1])
      
      DispatchQueue.main.async {
        self.summary.saturdayLow = Formatters.format(temp: saturdayLow, from: .celsius)
        self.summary.saturdayHigh = Formatters.format(temp: saturdayHigh, from: .celsius)
        self.summary.saturdayCondition = forecastDays[0].condition_text ?? ""
        self.summary.sundayLow = Formatters.format(temp: sundayLow, from: .celsius)
        self.summary.sundayHigh = Formatters.format(temp: sundayHigh, from: .celsius)
        self.summary.sundayCondition = forecastDays[1].condition_text ?? ""
        self.summary.saturdayPrecipitation = saturdayPrecipitationResult.0
        self.summary.saturdayPrecipitationType = saturdayPrecipitationResult.1
        self.summary.saturdayPrecipitationPercent = saturdayPrecipitationResult.2
        self.summary.sundayPrecipitation = sundayPrecipitationResult.0
        self.summary.sundayPrecipitationType = sundayPrecipitationResult.1
        self.summary.sundayPrecipitationPercent = sundayPrecipitationResult.2
      }
    }
  }
  
  func setPrecipitation(forecastDay: TGWForecastDay) -> (Bool, String, String) {
    var precipitation = false
    var precipitationType = ""
    var precipitationPercent = ""
    if forecastDay.daily_will_it_rain == 1 || forecastDay.daily_will_it_snow == 1 {
      precipitation = true
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
    return (precipitation, precipitationType, precipitationPercent)
  }
}
