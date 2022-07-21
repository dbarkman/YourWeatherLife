//
//  EventProvider.swift
//  YourWeatherLife
//
//  Created by David Barkman on 7/3/22.
//

import Foundation
import CoreData
import OSLog

struct EventProvider {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "EventProvider")
  
  var viewCloudContext = CloudPersistenceController.shared.container.viewContext
  
  static let shared = EventProvider()
  
  func importEventsFromSeed() async {
    logger.debug("Importing seed events.")
    do {
      if let url = Bundle.main.url(forResource: "seedData", withExtension: "json") {
        let data = try Data(contentsOf: url)
        await decodeEvents(data: data)
      }
    } catch {
      logger.error("Could not extract data from seedData.json. 😭 \(error.localizedDescription)")
    }
  }
  
  private func decodeEvents(data: Data) async {
    do {
      let jsonDecoder = JSONDecoder()
      let eventDecoder = try jsonDecoder.decode(EventDecoder.self, from: data)
      _ = insertEvents(eventList: eventDecoder.eventList)
    } catch {
      logger.error("Failed to decode data when fetching Events. 😭 \(error.localizedDescription)")
    }
  }
  
  func insertEvents(eventList: [Event]) -> EventResult {
    var result = EventResult.noResult
    let fetchRequest: NSFetchRequest<DailyEvent>
    fetchRequest = DailyEvent.fetchRequest()
    for event in eventList {
      fetchRequest.predicate = NSPredicate(format: "event = %@", event.event)
      do {
        let dailyEvent = try viewCloudContext.fetch(fetchRequest)
        if dailyEvent.count == 0 {
          let newDailyEvent = DailyEvent(context: viewCloudContext)
          newDailyEvent.event = event.event
          newDailyEvent.startTime = event.startTime
          newDailyEvent.endTime = event.endTime
          newDailyEvent.days = event.days
          do {
            try viewCloudContext.save()
            result = .eventSaved
          } catch {
            logger.error("Could not save Daily Event: \(event.event)")
            result = .eventNotSaved
          }
        } else {
          result = .eventExists
          continue
        }
      } catch {
        logger.error("Could not fetch Daily Events. 😭 \(error.localizedDescription)")
        result = .eventError
      }
    }
    UserDefaults.standard.set(true, forKey: "defaultEventsLoaded")
    logger.debug("Events imported successfully! 🎉")
    return result
  }
  
  func updateEvents(event: Event, oldEventName: String) -> EventResult {
    var result = EventResult.noResult
    let fetchRequest: NSFetchRequest<DailyEvent>
    fetchRequest = DailyEvent.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "event = %@", oldEventName)
    do {
      let dailyEvents = try viewCloudContext.fetch(fetchRequest)
      for dailyEvent in dailyEvents {
        dailyEvent.setValue(event.event, forKey: "event")
        dailyEvent.setValue(event.startTime, forKey: "startTime")
        dailyEvent.setValue(event.endTime, forKey: "endTime")
        dailyEvent.setValue("", forKey: "when")
        dailyEvent.setValue("", forKey: "nextStartDate")
        dailyEvent.setValue("", forKey: "summary")
        dailyEvent.setValue(event.days, forKey: "days")
        do {
          try viewCloudContext.save()
          result = .eventSaved
        } catch {
          logger.error("Could not save Daily Event: \(event.event)")
          result = .eventNotSaved
        }
      }
    } catch {
      logger.error("Could not fetch Daily Events. 😭 \(error.localizedDescription)")
      result = .eventError
    }
    return result
  }
}
