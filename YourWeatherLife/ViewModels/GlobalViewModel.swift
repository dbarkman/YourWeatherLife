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
  
  @Published var isShowingDailyEvents = false
  @Published var events = [Event]()
  
  init(viewContext: NSManagedObjectContext) {
    self.viewContext = viewContext
  }

  //MARK: EditEventPencil
  
  func showDailyEvents() {
    Mixpanel.mainInstance().track(event: "Showing DailyEvents")
    isShowingDailyEvents.toggle()
  }
  
  func createEventList() {
    let event1 = Event(id: UUID(), event: "Morning Commute", startTime: "7:00", endTime: "9:00", summary: "")
    let event2 = Event(id: UUID(), event: "Lunch", startTime: "11:00", endTime: "12:00", summary: "")
    let event3 = Event(id: UUID(), event: "Afternoon Commute", startTime: "16:00", endTime: "18:00", summary: "")
    var events = [event1, event2, event3]
    
    var index = 0
    for event in events {
      let start = event.startTime
      let end = event.endTime
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
      if let objects = try? viewContext.fetch(fetchRequest) {
        let summary = EventSummary()
        let eventSummary = summary.creatSummary(hoursForecast: objects)
        events[index].summary = eventSummary
      }
      index += 1
    }
    self.events = events
  }
}
