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
    do {
      let url = Bundle.main.url(forResource: "seedData", withExtension: "json")!
      let data = try Data(contentsOf: url)
      await decodeEvents(data: data)
    } catch {
      logger.error("Could not extract data from seedData.json. 😭 \(error.localizedDescription)")
    }
  }
  
  private func decodeEvents(data: Data) async {
    do {
      let jsonDecoder = JSONDecoder()
      let eventDecoder = try jsonDecoder.decode(EventDecoder.self, from: data)
      let eventList = eventDecoder.eventList
      await importEvents(from: eventList)
    } catch {
      logger.error("Failed to decode data when fetching Events. 😭 \(error.localizedDescription)")
    }
  }
  
  private func importEvents(from eventList: [Event]) async {
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
      logger.error("Failed to execute batch insert request. 😭")
    }
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
