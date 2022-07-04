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
  
  static let shared = EventProvider()
  
  func importEventsFromSeed() async {
    logger.debug("Importing events from seed.")
    do {
      let url = Bundle.main.url(forResource: "seedData", withExtension: "json")!
      let data = try Data(contentsOf: url)
      await decodeEvents(data: data)
    } catch {
      logger.debug("Could not extract data from seedData.json")
    }
  }
  
  private func decodeEvents(data: Data) async {
    logger.debug("Decoding events.")
    do {
      let jsonDecoder = JSONDecoder()
      let eventDecoder = try jsonDecoder.decode(EventDecoder.self, from: data)
      let eventList = eventDecoder.eventList
      logger.debug("Sending eventList to CD import.")
      await importEvents(from: eventList)
    } catch {
      logger.debug("Failed to decode data when fetching Events.")
    }
  }
  
  private func importEvents(from eventList: [Event]) async {
    logger.debug("Importing events.")
    guard !eventList.isEmpty else { return }
    
    let taskContext = newTaskContext()
    taskContext.name = "importContext"
    taskContext.transactionAuthor = "importEvents"
    
    await taskContext.perform {
      let batchInsertRequest = self.newBatchInsertRequest(with: eventList)
      if let fetchResult = try? taskContext.execute(batchInsertRequest),
         let batchInsertResult = fetchResult as? NSBatchInsertResult,
         let success = batchInsertResult.result as? Bool, success {
        return
      }
      logger.debug("Failed to execute batch insert request.")
    }
    logger.debug("Successfully inserted events. 🎉")
  }
  
  private func newBatchInsertRequest(with eventList: [Event]) -> NSBatchInsertRequest {
    var index = 0
    let total = eventList.count
    let batchInsertRequest = NSBatchInsertRequest(entity: DailyEvent.entity(), dictionaryHandler: { dictionary in
      guard index < total else { return true }
      dictionary.addEntries(from: eventList[index].dictionaryValue)
      index += 1
      return false
    })
    return batchInsertRequest
  }
  
  private func newTaskContext() -> NSManagedObjectContext {
    let container = CloudPersistenceController.shared.container
    let taskContext = container.newBackgroundContext()
    taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy //adjust this to affect data overwriting, Object = Event overwrites local storage, Store = Event cannot overwrite local storage
    return taskContext
  }
}
