//
//  CalendarEventProvider.swift
//  YourWeatherLife
//
//  Created by David Barkman on 8/7/22.
//

import Foundation
import CoreData
import EventKit
import OSLog

struct CalendarEventProvider {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "CalendarEventProvider")
  
  static let shared = CalendarEventProvider()
  
  var viewCloudContext = CloudPersistenceController.shared.container.viewContext
  
  private init() { }
  
  func insertCalendarEvents(calendarEventList: [EKEvent]) {
//    let fetchRequest: NSFetchRequest<CalendarEvent>
//    fetchRequest = CalendarEvent.fetchRequest()
    for calendarEvent in calendarEventList {
      let id = calendarEvent.eventIdentifier ?? ""
//      fetchRequest.predicate = NSPredicate(format: "identifier = %@", id)
//      do {
//        let calendarEvents = try viewCloudContext.fetch(fetchRequest)
//        if calendarEvents.count == 0 {
          let newCalendarEvent = CalendarEvent(context: viewCloudContext)
          newCalendarEvent.identifier = calendarEvent.eventIdentifier
          do {
            try viewCloudContext.save()
          } catch {
            logger.error("Could not save Calendar Event: \(calendarEvent.title)")
          }
//        } else {
//          logger.error("Calendar Event: \(calendarEvent.title), already exists")
//          updateCalendarEvent(calendarEvent: calendarEvent)
//          continue
//        }
//      } catch {
//        logger.error("Could not fetch Calendar Events: 😭 \(error.localizedDescription)")
//      }
    }
  }
  
  func updateCalendarEvent(calendarEvent: EKEvent) {
    let fetchRequest: NSFetchRequest<CalendarEvent>
    fetchRequest = CalendarEvent.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "id = %@", calendarEvent.calendarItemIdentifier)
    do {
      let calendarEvents = try viewCloudContext.fetch(fetchRequest)
      for calEvent in calendarEvents {
        calEvent.setValue(calendarEvent.title, forKey: "title")
        calEvent.setValue(calendarEvent.startDate, forKey: "startDate")
        calEvent.setValue(calendarEvent.endDate, forKey: "endDate")
        calEvent.setValue(calendarEvent.isAllDay, forKey: "isAllDay")
        calEvent.setValue(calendarEvent.timeZone?.description, forKey: "timeZone")
        calEvent.setValue(calendarEvent.location, forKey: "location")
        do {
          try viewCloudContext.save()
        } catch {
          logger.error("Could not update Calendar Event: \(calendarEvent.title)")
        }
      }
    } catch {
      logger.error("Could not fetch Calendar Events: 😭 \(error.localizedDescription)")
    }
  }
}
