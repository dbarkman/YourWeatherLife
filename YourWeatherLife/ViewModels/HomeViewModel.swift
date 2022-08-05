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

  @Published var isShowingDailyEvents = false
  @Published var todayEvents = [EventForecast]()
  @Published var todayEventForecastHours = [String: [TGWForecastHour]]()
  @Published var tomorrowEvents = [EventForecast]()
  @Published var tomorrowEventForecastHours = [String: [TGWForecastHour]]()
  @Published var laterEvents = [EventForecast]()
  @Published var laterEventForecastHours = [String: [TGWForecastHour]]()
  @Published var showiCloudLoginAlert = false
  @Published var showiCloudFetchAlert = false
  @Published var showNoLocationAlert = false

  private var todayEventsList = [EventForecast]()
  private var tomorrowEventsList = [EventForecast]()
  private var laterEventsList = [EventForecast]()

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
    _ = createUpdateEventList()
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
      let startTime = Dates.shared.makeDisplayTimeFromTime(time: start, format: "HH:mm")
      let endTime = Dates.shared.makeDisplayTimeFromTime(time: end, format: "HH:mm")
      var predicate = ""
      for event in eventArray {
        predicate.append("'\(event)',")
      }
      let finalPredicate = predicate.dropLast()
      let location = UserDefaults.standard.string(forKey: "currentConditionsLocation") ?? "Kirkland"
      let fetchRequest: NSFetchRequest<TGWForecastHour>
      fetchRequest = TGWForecastHour.fetchRequest()
      fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TGWForecastHour.time_epoch, ascending: true)]
      fetchRequest.predicate = NSPredicate(format: "dateTime IN {\(finalPredicate)} AND location = %@", location)
      var forecastHours: [TGWForecastHour] = []
      do {
        forecastHours = try viewContext.fetch(fetchRequest)
      } catch {
        logger.error("Couldn't fetch TGWForecastHour. 😭 \(error.localizedDescription)")
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
  
  func showDailyEvents() {
    Mixpanel.mainInstance().track(event: "Showing DailyEvents")
    isShowingDailyEvents.toggle()
  }
  
  func disableiCloudSync() async {
    Mixpanel.mainInstance().track(event: "Disable iCloud Sync")
    UserDefaults.standard.set(false, forKey: "userNotLoggedIniCloud")
    UserDefaults.standard.set(true, forKey: "disableiCloudSync")
    await EventProvider.shared.importEventsFromSeed()
    await DataService.shared.updateNextStartDate()
  }
}
