//
//  DataService.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/21/22.
//

import Foundation
import OSLog
import CoreData

struct DataService {

  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "DataService")
  var localContainer = LocalPersistenceController.shared.container
  var cloudContainer = CloudPersistenceController.shared.container

  func fetchAPIsFromCloud() async {
    await APIsProvider.shared.fetchAPIs()
  }
  
  func fetchPrimaryAPIFromLocal () async -> API {
    if !UserDefaults.standard.bool(forKey: "apisFetched") {
      await DataService().fetchAPIsFromCloud()
      UserDefaults.standard.set(true, forKey: "apisFetched")
      return await fetchPrimaryAPIFromLocal()
    } else {
      let request = API.fetchRequest()
      request.sortDescriptors = [NSSortDescriptor(keyPath: \API.priority, ascending: true)]
      request.fetchLimit = 1
      do {
        if let api = try localContainer.viewContext.fetch(request).first as? API {
          return api
        }
      } catch {
        logger.debug("Error loading APIs from local 😭")
      }
    }
    return API()
  }
  
  func fetchAPIFromLocalBy(shortName: String) -> API {
    let request = API.fetchRequest()
    request.predicate = NSPredicate(format: "shortName = %@", shortName)
    request.fetchLimit = 1
    do {
      if let api = try localContainer.viewContext.fetch(request).first as? API {
        return api
      }
    } catch {
      logger.debug("Fetch API from local by name failed 😭")
    }
    return API()
  }
  
  func updateNextStartDate() async {
    let fetchRequest: NSFetchRequest<DailyEvent>
    fetchRequest = DailyEvent.fetchRequest()
    if let dailyEventList = try? cloudContainer.viewContext.fetch(fetchRequest) {
      for dailyEvent in dailyEventList {
        let start = dailyEvent.startTime ?? "00:00"
        let end = dailyEvent.endTime ?? "00:00"
        let nextStartDate = Dates.getEventHours(start: start, end: end, startOnly: true)[0]
        dailyEvent.setValue(nextStartDate, forKey: "nextStartDate")
        do {
          try cloudContainer.viewContext.save()
        } catch {
          logger.debug("Could not save nextStartDate. 😭")
        }
      }
    }
  }
}
