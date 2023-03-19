//
//  CalendarEventViewModel.swift
//  YourWeatherLife
//
//  Created by David Barkman on 8/7/22.
//

import Foundation
import CoreData
import OSLog

class CalendarEventViewModel: ObservableObject {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "CalendarEventViewModel")
  
  static let shared = CalendarEventViewModel()
  
  private var viewCloudContext = CloudPersistenceController.shared.container.viewContext
  
  @Published var selectedCalendarEvents: Set<String> = []
  
  private init() { }
  
  func fetchCalendarEvents() {
    DispatchQueue.main.async {
      self.selectedCalendarEvents.removeAll()
    }
    let today = Date()
    let fetchRequest: NSFetchRequest<CalendarEvent>
    fetchRequest = CalendarEvent.fetchRequest()
//    fetchRequest.predicate = NSPredicate(format: "startDate >= %@", today as CVarArg)
    do {
      let calendarEvents = try viewCloudContext.fetch(fetchRequest)
      var eventsTitles: Set<String> = []
      for calendarEvent in calendarEvents {
//        let title = calendarEvent.title ?? ""
//        let startDate = calendarEvent.startDate ?? Date()
//        var date = Dates.shared.makeStringFromDate(date: startDate, format: "EEEE, MMMM d' at 'h:mm a")
//        if calendarEvent.isAllDay {
//          date = Dates.shared.makeStringFromDate(date: startDate, format: "EEEE, MMMM d")
//        }
//        eventsTitles.insert("\(title) on \(date)")
      }
      DispatchQueue.main.async {
        self.selectedCalendarEvents = eventsTitles
      }
    } catch {
      logger.error("Could not fetch Calendar Events: 😭 \(error.localizedDescription)")
    }
  }
}
