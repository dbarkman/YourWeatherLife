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
  
  var globalViewModel: GlobalViewModel?
  
  @Published var todayEvents = [EventForecast]()
  @Published var todayEventForecastHours = [String: [TGWForecastHour]]()
  @Published var tomorrowEvents = [EventForecast]()
  @Published var tomorrowEventForecastHours = [String: [TGWForecastHour]]()
  @Published var forecastDays = [Today]()
  @Published var forecastHours = [HourForecast]()
  @Published var showiCloudLoginAlert = false
  @Published var showiCloudFetchAlert = false

  private var todayEventsList = [EventForecast]()
  private var todayEventForecastHoursList = [String: [TGWForecastHour]]()
  private var tomorrowEventsList = [EventForecast]()
  private var tomorrowEventForecastHoursList = [String: [TGWForecastHour]]()

  init() {
    NotificationCenter.default.addObserver(self, selector: #selector(overrideFetchForcast), name: .locationUpdatedEvent, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(overrideUpdateEventList), name: .nextStartDateUpdated, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(objcUpdateNextStartDate), name: .forecastInsertedEvent, object: nil)
  }
  
  @objc func overrideFetchForcast() {
    if let globalViewModel = globalViewModel {
      if globalViewModel.networkOnline {
        let nextUpdate = Date(timeIntervalSince1970: 0)
        UserDefaults.standard.set(nextUpdate, forKey: "forecastsNextUpdate")
        fetchForecast()
      }
    }
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
      await DataService.shared.updateNextStartDate()
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

  private func createUpdateEventList() async {
    logger.debug("Creating/updating event list.")
    todayEventsList.removeAll()
    tomorrowEventsList.removeAll()
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
      if !todayEventsList.contains(event) && !tomorrowEventsList.contains(event) {
        if event.tomorrow.isEmpty { //today
          todayEventsList.append(event)
          todayEventForecastHoursList[eventName] = forecastHours
        } else { //tomorrow
          tomorrowEventsList.append(event)
          tomorrowEventForecastHoursList[eventName] = forecastHours
        }
      }
    }
    DispatchQueue.main.async {
      self.todayEvents.removeAll()
      self.tomorrowEvents.removeAll()
      self.todayEvents = self.todayEventsList
      self.tomorrowEvents = self.tomorrowEventsList
      self.todayEventForecastHours.removeAll()
      self.tomorrowEventForecastHours.removeAll()
      self.todayEventForecastHours = self.todayEventForecastHoursList
      self.tomorrowEventForecastHours = self.tomorrowEventForecastHoursList
    }
  }
  
  func create14DayForecast() {
    let dateTimeFormatter = DateFormatter()
    dateTimeFormatter.dateFormat = "yyyy-MM-dd"
    let today = dateTimeFormatter.string(from: Date())
    let fetchRequest: NSFetchRequest<TGWForecastDay>
    fetchRequest = TGWForecastDay.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "date >= %@", today)
    var forecastDays = [Today]()
    do {
      let forecastDay = try viewContext.fetch(fetchRequest)
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
    } catch {
      logger.error("Couldn't fetch 14 day forecast. 😭 \(error.localizedDescription)")
    }
    DispatchQueue.main.async {
      self.forecastDays = forecastDays
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
  
  func disableiCloudSync() async {
    UserDefaults.standard.set(false, forKey: "userNotLoggedIniCloud")
    UserDefaults.standard.set(true, forKey: "disableiCloudSync")
    await EventProvider.shared.importEventsFromSeed()
    await DataService.shared.updateNextStartDate()
  }
}
