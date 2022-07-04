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
  @Published var events = [Event]()
  private var eventsList = [Event]()

  
  init(viewContext: NSManagedObjectContext, viewCloudContext: NSManagedObjectContext) {
    self.viewContext = viewContext
    self.viewCloudContext = viewCloudContext
  }

  //MARK: EditEventPencil
  
  func showDailyEvents() {
    Mixpanel.mainInstance().track(event: "Showing DailyEvents")
    isShowingDailyEvents.toggle()
  }
  
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
      if let dailyEventList = try? viewCloudContext.fetch(fetchRequest) {
        for dailyEvent in dailyEventList {
          let eventName = dailyEvent.event ?? ""
          let start = dailyEvent.startTime ?? "00:00"
          let end = dailyEvent.endTime ?? "00:00"
          let startTime = Dates.makeDisplayTimeFromTime(time: start)
          let endTime = Dates.makeDisplayTimeFromTime(time: end)
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
          if let forecastHours = try? viewContext.fetch(fetchRequest) {
            let summary = EventSummary()
            let eventSummary = summary.creatSummary(hoursForecast: forecastHours)
            let event = Event(event: eventName, startTime: startTime, endTime: endTime, summary: eventSummary, nextStartDate: "")
            eventsList.append(event)
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
