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
  var container = LocalPersistenceController.shared.container

  func fetchAPIsFromCloud() async {
    do {
      try await APIsProvider.shared.fetchAPIs()
    } catch {
      logger.error("Error loading APIs: \(error.localizedDescription)")
    }
  }
  
  func fetchPrimaryAPIFromLocal () -> API {
    let request = API.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(keyPath: \API.priority, ascending: true)]
    request.fetchLimit = 1
    do {
      if let api = try container.viewContext.fetch(request).first as? API {
        return api
      }
    } catch {
      logger.debug("Fetch failed 😭")
    }
    return API()
  }
  
  func fetchAPIFromLocalBy(shortName: String) -> API {
    let request = API.fetchRequest()
    request.predicate = NSPredicate(format: "shortName = %@", shortName)
    request.fetchLimit = 1
    do {
      if let api = try container.viewContext.fetch(request).first as? API {
        return api
      }
    } catch {
      logger.debug("Fetch API from local by name failed 😭")
    }
    return API()
  }

}
