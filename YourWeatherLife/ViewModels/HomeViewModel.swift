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
  
  static let shared = HomeViewModel()
  var globalViewModel = GlobalViewModel.shared

  private var viewContext = LocalPersistenceController.shared.container.viewContext
  private var viewCloudContext = CloudPersistenceController.shared.container.viewContext
  
  @Published var todayEvents = [EventForecast]()
  @Published var todayEventForecastHours = [String: [TGWForecastHour]]()
  @Published var tomorrowEvents = [EventForecast]()
  @Published var tomorrowEventForecastHours = [String: [TGWForecastHour]]()
  @Published var laterEvents = [EventForecast]()
  @Published var laterEventForecastHours = [String: [TGWForecastHour]]()
  @Published var forecastDays = [Today]()
  @Published var forecastHours = [HourForecast]()
  @Published var showiCloudLoginAlert = false
  @Published var showiCloudFetchAlert = false
  @Published var showNoLocationAlert = false

  private var todayEventsList = [EventForecast]()
  private var todayEventForecastHoursList = [String: [TGWForecastHour]]()
  private var tomorrowEventsList = [EventForecast]()
  private var tomorrowEventForecastHoursList = [String: [TGWForecastHour]]()
  private var laterEventsList = [EventForecast]()
  private var laterEventForecastHoursList = [String: [TGWForecastHour]]()

  private init() {
    NotificationCenter.default.addObserver(self, selector: #selector(overrideFetchForcast), name: .locationUpdatedEvent, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(overrideUpdateEventList), name: .nextStartDateUpdated, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(objcUpdateNextStartDate), name: .forecastInsertedEvent, object: nil)
  }
  
  @objc private func overrideFetchForcast() {
    if globalViewModel.networkOnline {
      logger.debug("Location updated, fetching forecast.")
      let nextUpdate = Date(timeIntervalSince1970: 0)
      UserDefaults.standard.set(nextUpdate, forKey: "forecastsNextUpdate")
      fetchForecast()
    }
    let authorizationStatus = LocationViewModel.shared.authorizationStatus
    if authorizationStatus != .authorizedAlways && authorizationStatus != .authorizedWhenInUse {
      showNoLocationAlert = true
    }
  }
  func fetchForecast() {
    Task {
      await GetAllData.shared.updateForecasts()
    }
  }
  
  @objc private func objcUpdateNextStartDate() {
    awaitUpdateNextStartDate()
  }
  func awaitUpdateNextStartDate() {
    Task {
      await DataService.shared.updateNextStartDate()
    }
  }
  
  @objc private func overrideUpdateEventList() {
    updateEventList()
  }
  private func updateEventList() {
    viewContext.refreshAllObjects()
    createUpdateEventList()
  }

  private func createUpdateEventList() {
    logger.debug("Creating/updating event list.")
    todayEventsList.removeAll()
    tomorrowEventsList.removeAll()
    laterEventsList.removeAll()
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
      let when = dailyEvent.when ?? ""
      let days = dailyEvent.days ?? "1234567"
      let nextStartDateTime = dailyEvent.nextStartDate ?? Dates.shared.makeStringFromDate(date: Date(), format: "yyyy-MM-dd")
      let nextStartDateString = String(nextStartDateTime.prefix(10))
      let nextStartDate = Dates.shared.makeDateFromString(date: nextStartDateString, format: "yyyy-MM-dd")
      let eventArray = Dates.shared.getEventHours(start: start, end: end, date: nextStartDate)
      let startTime = Dates.shared.makeDisplayTimeFromTime(time: start, format: "HH:mm")
      let endTime = Dates.shared.makeDisplayTimeFromTime(time: end, format: "HH:mm")
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
        hours.append(DayDetailViewModel.shared.configureHour(hour: hour))
      }
      let summary = EventSummaryProvider.shared
      let eventSummary = summary.creatSummary(hoursForecast: forecastHours)
      let event = EventForecast(eventName: eventName, startTime: startTime, endTime: endTime, summary: eventSummary, nextStartDate: "", when: when, days: days, forecastHours: hours)
      if !todayEventsList.contains(event) && !tomorrowEventsList.contains(event) {
        if event.when == "Today" { //today
          todayEventsList.append(event)
          todayEventForecastHoursList[eventName] = forecastHours
        } else if event.when == "Tomorrow" { //tomorrow
          tomorrowEventsList.append(event)
          tomorrowEventForecastHoursList[eventName] = forecastHours
        } else { //later
          laterEventsList.append(event)
          laterEventForecastHoursList[eventName] = forecastHours
        }
      }
    }
    DispatchQueue.main.async {
      self.todayEvents.removeAll()
      self.tomorrowEvents.removeAll()
      self.laterEvents.removeAll()
      self.todayEvents = self.todayEventsList
      self.tomorrowEvents = self.tomorrowEventsList
      self.laterEvents = self.laterEventsList
      self.todayEventForecastHours.removeAll()
      self.tomorrowEventForecastHours.removeAll()
      self.laterEventForecastHours.removeAll()
      self.todayEventForecastHours = self.todayEventForecastHoursList
      self.tomorrowEventForecastHours = self.tomorrowEventForecastHoursList
      self.laterEventForecastHours = self.laterEventForecastHoursList
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
        let todayResult = TodaySummaryViewModel.shared.configureDay(todayForecast: day)
        var today = todayResult.0
        let hours = todayResult.1
        var hoursForecast = [HourForecast]()
        for hour in hours {
          hoursForecast.append(DayDetailViewModel.shared.configureHour(hour: hour))
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
        hours.append(DayDetailViewModel.shared.configureHour(hour: hour))
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
