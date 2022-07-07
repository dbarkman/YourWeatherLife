//
//  GlobalViewModel.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/11/22.
//

import Foundation
import Mixpanel
import OSLog
import CoreData

class GlobalViewModel: ObservableObject {

  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "GlobalViewModel")

  var viewContext: NSManagedObjectContext
  var viewCloudContext: NSManagedObjectContext

  @Published var isShowingDailyEvents = false
  @Published var events = [EventForecast]()
  @Published var eventForecastHours = [String: [TGWForecastHour]]()
  @Published var today = Dates.getTodayDateString(format: "yyyy-MM-dd")
  @Published var weekend = Dates.getThisWeekendDateStrings(format: "yyyy-MM-dd")
  
  private var eventsList = [EventForecast]()
  
  init(viewContext: NSManagedObjectContext, viewCloudContext: NSManagedObjectContext) {
    self.viewContext = viewContext
    self.viewCloudContext = viewCloudContext
    NotificationCenter.default.addObserver(self, selector: #selector(overrideFetchForcastAndUpdateEventList), name: .locationUpdatedEvent, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(overrideUpdateEventList), name: .forecastInsertedEvent, object: nil)
  }

  @objc func overrideFetchForcastAndUpdateEventList() {
    let nextUpdate = Date(timeIntervalSince1970: 0)
    UserDefaults.standard.set(nextUpdate, forKey: "forecastsNextUpdate")
    fetchForecastAndUpdateEventList()
  }
  
  @objc func overrideUpdateEventList() {
    updateEventList()
  }
  
  func fetchForecastAndUpdateEventList() {
    Task {
      await GetAllData.shared.getAllData()
//      await createEventList(from: "gvm.fetchForecastAndUpdateEventList")
    }
  }
  
  func updateEventList() {
    Task {
      await createEventList()
    }
  }
  
  //MARK: EditEventPencil
  
  func showDailyEvents() {
    Mixpanel.mainInstance().track(event: "Showing DailyEvents")
    isShowingDailyEvents.toggle()
  }
  
  //MARK: EventList
  
  func createEventList() async {
    if !UserDefaults.standard.bool(forKey: "defaultEventsLoaded") {
      await EventProvider.shared.importEventsFromSeed()
      await DataService().updateNextStartDate()
      UserDefaults.standard.set(true, forKey: "defaultEventsLoaded")
      await createEventList()
    } else {
      eventsList.removeAll()
      let fetchRequest: NSFetchRequest<DailyEvent>
      fetchRequest = DailyEvent.fetchRequest()
      fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \DailyEvent.nextStartDate, ascending: true)]
      if let dailyEventList = try? viewCloudContext.fetch(fetchRequest) {
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
          viewContext.refreshAllObjects()
          if let forecastHours = try? viewContext.fetch(fetchRequest) {
            var hours = [HourForecast]()
            for hour in forecastHours {
              hours.append(DayDetailViewModel().configureHour(hour: hour))
            }
            let summary = EventSummary()
            let eventSummary = summary.creatSummary(hoursForecast: forecastHours)
            let event = EventForecast(eventName: eventName, startTime: startTime, endTime: endTime, summary: eventSummary, nextStartDate: "", tomorrow: tomorrow, forecastHours: hours)
//            return
            eventsList.append(event)
            DispatchQueue.main.async {
              self.eventForecastHours[eventName] = forecastHours
//              print(self.eventForecastHours["Afternoon Commute"])
            }
          }
        }
      }
    }
    DispatchQueue.main.async {
      self.events.removeAll()
      self.events = self.eventsList
    }
  }
  
}
