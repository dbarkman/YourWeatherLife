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
  var viewCloudContext = CloudPersistenceController.shared.container.viewContext
  
  @Published var events = [EventForecast]()
  @Published var eventForecastHours = [String: [TGWForecastHour]]()
  @Published var forecastDays = [Today]()
  @Published var forecastHours = [HourForecast]()

  private var eventsList = [EventForecast]()
  private var eventForecastHoursList = [String: [TGWForecastHour]]()

  init() {
    NotificationCenter.default.addObserver(self, selector: #selector(overrideFetchForcast), name: .locationUpdatedEvent, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(objcUpdateNextStartDate), name: .forecastInsertedEvent, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(overrideUpdateEventList), name: .nextStartDateUpdated, object: nil)
  }
  
  @objc func overrideFetchForcast() {
    let nextUpdate = Date(timeIntervalSince1970: 0)
    UserDefaults.standard.set(nextUpdate, forKey: "forecastsNextUpdate")
    fetchForecast()
  }
  func fetchForecast() {
    Task {
      await GetAllData.shared.updateForecasts()
    }
  }
  
  @objc func objcUpdateNextStartDate() {
    awaitUpdateNextStartDate()
  }
  func awaitUpdateNextStartDate() {
    Task {
      await DataService.shared.updateNextStartDate(who: "homeViewModel")
    }
  }
  
  @objc func overrideUpdateEventList() {
    updateEventList()
  }
  func updateEventList() {
    Task {
      await createUpdateEventList()
    }
  }

  func createUpdateEventList() async {
    logger.debug("Creating/updating event list.")
    eventsList.removeAll()
    let fetchRequest: NSFetchRequest<DailyEvent>
    fetchRequest = DailyEvent.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \DailyEvent.nextStartDate, ascending: true)]
    var dailyEventList: [DailyEvent] = []
    do {
      dailyEventList = try viewCloudContext.fetch(fetchRequest)
    } catch {
      logger.error("Couldn't fetch DailyEvent. 😭 \(error.localizedDescription)")
      return
    }
    for dailyEvent in dailyEventList {
      let eventName = dailyEvent.event ?? ""
      let start = dailyEvent.startTime ?? "00:00"
      let end = dailyEvent.endTime ?? "00:00"
      let tomorrow = dailyEvent.tomorrow ?? ""
      let startTime = Dates.makeDisplayTimeFromTime(time: start, format: "HH:mm")
      let endTime = Dates.makeDisplayTimeFromTime(time: end, format: "HH:mm")
      let eventArray = Dates.getEventHours(start: start, end: end)
      var predicate = ""
      for event in eventArray {
        predicate.append("'\(event)',")
      }
      let finalPredicate = predicate.dropLast()
      let fetchRequest: NSFetchRequest<TGWForecastHour>
      fetchRequest = TGWForecastHour.fetchRequest()
      fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TGWForecastHour.time_epoch, ascending: true)]
      fetchRequest.predicate = NSPredicate(format: "dateTime IN {\(finalPredicate)}")
      var forecastHours: [TGWForecastHour] = []
      do {
        forecastHours = try viewContext.fetch(fetchRequest)
      } catch {
        logger.error("Couldn't fetch TGWForecastHour. 😭 \(error.localizedDescription)")
        return
      }
      var hours = [HourForecast]()
      for hour in forecastHours {
        hours.append(DayDetailViewModel().configureHour(hour: hour))
      }
      let summary = EventSummary()
      let eventSummary = summary.creatSummary(hoursForecast: forecastHours)
      let event = EventForecast(eventName: eventName, startTime: startTime, endTime: endTime, summary: eventSummary, nextStartDate: "", tomorrow: tomorrow, forecastHours: hours)
      eventsList.append(event)
      eventForecastHoursList[eventName] = forecastHours
    }
    DispatchQueue.main.async {
      self.events.removeAll()
      self.events = self.eventsList
      self.eventForecastHours.removeAll()
      self.eventForecastHours = self.eventForecastHoursList
      self.viewContext.refreshAllObjects()
      self.viewCloudContext.refreshAllObjects()
    }
  }
  
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
      logger.error("Couldn't fetch 14 day forecast. 😭 \(error.localizedDescription)")
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
      logger.error("Couldn't fetch 336 hour forecast. 😭 \(error.localizedDescription)")
    }
  }

}
