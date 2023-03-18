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
  
  func insertCalendarEvents(selectedEvents: [String], eventIdsByName: [String:String]) {
    //make an array of ids
    var calendarEventIdsList: [String] = []
    for event in selectedEvents {
      let calendarEventIdentifier = eventIdsByName[event] ?? ""
      calendarEventIdsList.append(calendarEventIdentifier)
    }
    
    //grab all events in the db
    //if not in selectedEvents, remove
    var eventsToProcess = [CalendarEvent]()
    let fetchRequest = NSFetchRequest<CalendarEvent>(entityName: "CalendarEvent")
    do {
      eventsToProcess = try viewCloudContext.fetch(fetchRequest)
      for eventToProcess in eventsToProcess {
        if let identifier = eventToProcess.identifier {
          if !calendarEventIdsList.contains(identifier) {
            viewCloudContext.delete(eventToProcess)
          }
        }
      }
      try viewCloudContext.save()
    } catch {
      print("Fetch or delete activity failed 😭")
    }
    
    //process all events in selectedEvents
    //just try to add each one
    for eventId in calendarEventIdsList {
      if !eventsToProcess.contains(where: { $0.identifier == eventId }) {
        let newCalendarEvent = CalendarEvent(context: viewCloudContext)
        newCalendarEvent.identifier = eventId
        do {
          try viewCloudContext.save()
        } catch {
          logger.error("Could not save Calendar Event: \(eventId)")
        }
      }
    }
  }
  
}
