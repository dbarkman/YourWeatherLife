//
//  HomeViewModel.swift
//  YourWeatherLife
//
//  Created by David Barkman on 7/6/22.
//

import Foundation
import CoreData
import Mixpanel
import OSLog

class HomeViewModel: ObservableObject {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "HomeViewModel")
  
  static let shared = HomeViewModel()
  var globalViewModel = GlobalViewModel.shared
  
  private var viewContext = LocalPersistenceController.shared.container.viewContext
  private var viewCloudContext = CloudPersistenceController.shared.container.viewContext
  
  @Published var todayEvents = [EventForecast]()
  @Published var todayEventForecastHours = [String: [ForecastHour]]()
  @Published var tomorrowEvents = [EventForecast]()
  @Published var tomorrowEventForecastHours = [String: [ForecastHour]]()
  @Published var laterEvents = [EventForecast]()
  @Published var laterEventForecastHours = [String: [ForecastHour]]()
  @Published var showiCloudLoginAlert = false
  @Published var showiCloudFetchAlert = false
  @Published var showNoLocationAlert = false
  @Published var importEvents = [EventForecast]()
  @Published var importEventForecastHours = [String: [ForecastHour]]()
  
  private var todayEventsList = [EventForecast]()
  private var tomorrowEventsList = [EventForecast]()
  private var laterEventsList = [EventForecast]()
  private var importEventsList = [EventForecast]()
  
  private init() {
    NotificationCenter.default.addObserver(self, selector: #selector(overrideFetchForcast), name: .locationUpdatedEvent, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(objcUpdateNextStartDate), name: .forecastInsertedEvent, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(overrideUpdateEventList), name: .nextStartDateUpdated, object: nil)
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
      ForecastViewModel.shared.create14DayForecast()
      ForecastViewModel.shared.create336HourForecast()
      DayDetailViewModel.shared.fetchDayDetail(dates: [globalViewModel.today])
      await AlertsViewModel.shared.getAlerts()
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
  func updateEventList() {
    _ = createUpdateEventList()
    _ = fetchImportedEvents()
  }
  
  func createUpdateEventList(eventPredicate: String = "") -> EventForecast {
    logger.debug("Creating/updating event list.")
    todayEventsList.removeAll()
    tomorrowEventsList.removeAll()
    laterEventsList.removeAll()
    let fetchRequest: NSFetchRequest<DailyEvent>
    fetchRequest = DailyEvent.fetchRequest()
    if !eventPredicate.isEmpty {
      fetchRequest.predicate = NSPredicate(format: "event = %@", eventPredicate)
    }
    fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \DailyEvent.nextStartDate, ascending: true)]
    var dailyEventList: [DailyEvent] = []
    do {
      dailyEventList = try viewCloudContext.fetch(fetchRequest)
    } catch {
      logger.error("Couldn't fetch DailyEvent. 😭 \(error.localizedDescription)")
      return EventForecast()
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
      let startTime = Dates.shared.makeDisplayTimeFromTime(time: start, format: "HH:mm", full: true)
      let endTime = Dates.shared.makeDisplayTimeFromTime(time: end, format: "HH:mm", full: true)
      var predicate = ""
      for event in eventArray {
        predicate.append("'\(event)',")
      }
      let finalPredicate = predicate.dropLast()
      let location = UserDefaults.standard.string(forKey: "currentConditionsLocation") ?? "Kirkland"
      let fetchRequest: NSFetchRequest<ForecastHour>
      fetchRequest = ForecastHour.fetchRequest()
      fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ForecastHour.time_epoch, ascending: true)]
      fetchRequest.predicate = NSPredicate(format: "dateTime IN {\(finalPredicate)} AND location = %@", location)
      var forecastHours: [ForecastHour] = []
      do {
        forecastHours = try viewContext.fetch(fetchRequest)
      } catch {
        logger.error("Couldn't fetch ForecastHour. 😭 \(error.localizedDescription)")
        return EventForecast()
      }
      var hours = [HourForecast]()
      for hour in forecastHours {
        hours.append(globalViewModel.configureHour(hour: hour))
      }
      let summary = EventSummaryProvider.shared
      let eventSummary = summary.creatSummary(hoursForecast: forecastHours)
      let event = EventForecast(eventName: eventName, startTime: startTime, endTime: endTime, summary: eventSummary, nextStartDate: "", when: when, days: days, forecastHours: hours)
      if !eventPredicate.isEmpty {
        return event
      }
      if !todayEventsList.contains(event) && !tomorrowEventsList.contains(event) {
        if event.when == "Today" { //today
          todayEventsList.append(event)
        } else if event.when == "Tomorrow" { //tomorrow
          tomorrowEventsList.append(event)
        } else { //later
          laterEventsList.append(event)
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
    }
    return EventForecast()
  }
  
  func fetchImportedEvents(eventPredicate: String = "") -> EventForecast {
    logger.debug("Fetching imported events with predicate: \(eventPredicate).")
    importEventsList.removeAll()
    let fetchRequest: NSFetchRequest<CalendarEvent>
    fetchRequest = CalendarEvent.fetchRequest()
    if !eventPredicate.isEmpty {
      fetchRequest.predicate = NSPredicate(format: "identifier = %@", eventPredicate)
    }
    var dailyEventList: [CalendarEvent] = []
    do {
      dailyEventList = try viewCloudContext.fetch(fetchRequest)
    } catch {
      logger.error("Couldn't fetch DailyEvent. 😭 \(error.localizedDescription)")
      return EventForecast()
    }
    for dailyEvent in dailyEventList {
      if let identifier = dailyEvent.identifier, var eventStartDate = dailyEvent.startDate, var eventEndDate = dailyEvent.endDate {
        if let calendarEvent = EventStoreViewModel.shared.store.event(withIdentifier: identifier) {
          if eventEndDate > .now  {
            if Calendar.current.dateComponents([.day], from: eventStartDate, to: eventEndDate).day! > 0 {
              let daysSinceStart = Calendar.current.dateComponents([.day], from: eventStartDate, to: .now).day!
              let daysTillEnd = Calendar.current.dateComponents([.day], from: .now, to: eventEndDate).day!
              eventStartDate = Calendar.current.date(byAdding: .day, value: daysSinceStart, to: eventStartDate) ?? Date()
              eventEndDate = Calendar.current.date(byAdding: .day, value: daysTillEnd, to: eventEndDate) ?? Date()
            }
            let eventName = calendarEvent.title ?? ""
            logger.debug("event: \(eventName)")
            let start = Dates.shared.makeStringFromDate(date: eventStartDate, format: "HH:mm")
            let end = Dates.shared.makeStringFromDate(date: eventEndDate, format: "HH:mm")
            let days = "1234567"
            let dayFormat = Dates.shared.userFormatDayFirst() ? "EEEE, d MMMM" : "EEEE, MMMM d"
            let when = Dates.shared.makeStringFromDate(date: eventStartDate, format: dayFormat)
            let eventArray = Dates.shared.getEventHours(start: start, end: end, date: eventStartDate)
            let startTime = Dates.shared.makeStringFromDate(date: eventStartDate, format: "HH:mm")
            let endTime = Dates.shared.makeStringFromDate(date: eventEndDate, format: "HH:mm")
            let startDisplayTime = Dates.shared.makeDisplayTimeFromTime(time: startTime, format: "HH:mm", full: true)
            let endDisplayTime = Dates.shared.makeDisplayTimeFromTime(time: endTime, format: "HH:mm", full: true)
            
            var predicate = ""
            for event in eventArray {
              predicate.append("'\(event)',")
            }
            let finalPredicate = predicate.dropLast()
            let location = UserDefaults.standard.string(forKey: "currentConditionsLocation") ?? "Kirkland"
            let fetchRequest: NSFetchRequest<ForecastHour>
            fetchRequest = ForecastHour.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ForecastHour.time_epoch, ascending: true)]
            fetchRequest.predicate = NSPredicate(format: "dateTime IN {\(finalPredicate)} AND location = %@", location)
            var forecastHours: [ForecastHour] = []
            do {
              forecastHours = try viewContext.fetch(fetchRequest)
            } catch {
              logger.error("Couldn't fetch ForecastHour. 😭 \(error.localizedDescription)")
              return EventForecast()
            }
            var hours = [HourForecast]()
            for hour in forecastHours {
              hours.append(globalViewModel.configureHour(hour: hour))
            }
            
            let summary = EventSummaryProvider.shared
            let eventSummary = summary.creatSummary(hoursForecast: forecastHours)
            let event = EventForecast(eventName: eventName, startTime: startDisplayTime, endTime: endDisplayTime, summary: eventSummary, nextStartDate: "", when: when, days: days, forecastHours: hours, identifier: identifier, isAllDay: calendarEvent.isAllDay)
            if !eventPredicate.isEmpty {
              return event
            }
            importEventsList.append(event)
            
          } else {
            continue
          }
        }
      }
    }
    DispatchQueue.main.async {
      self.importEvents.removeAll()
      self.importEvents = self.importEventsList
      self.importEventForecastHours.removeAll()
    }
    return EventForecast()
  }
  
  func disableiCloudSync() async {
    Mixpanel.mainInstance().track(event: "Disable iCloud Sync")
    UserDefaults.standard.set(false, forKey: "userNotLoggedIniCloud")
    UserDefaults.standard.set(true, forKey: "disableiCloudSync")
    await EventProvider.shared.importEventsFromSeed()
    await DataService.shared.updateNextStartDate()
  }
}
