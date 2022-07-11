//
//  DataService.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/21/22.
//

import Foundation
import CoreData
import CloudKit
import OSLog

struct DataService {
  
  static let shared = DataService()
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "DataService")
  
  var viewCloudContext = CloudPersistenceController.shared.container.viewContext
  
  func fetchAPIsFromCloud() async {
    await APIsProvider.shared.fetchAPIs()
  }
  
  func fetchPrimaryAPIFromLocal () async -> API {
    let api = API()
    api.apiKey = APISettings.fetchAPISettings().tgwApiKey
    api.urlBase = APISettings.fetchAPISettings().tgwUrlBase
    return api
  }
  
  func fetchAPIFromLocalBy(shortName: String) -> API {
    let api = API()
    api.apiKey = APISettings.fetchAPISettings().tgwApiKey
    api.urlBase = APISettings.fetchAPISettings().tgwUrlBase
    return api
  }
  
  func updateNextStartDate(who: String) async {
    logger.debug("Updating next start date. 0 - \(who)")
    if !UserDefaults.standard.bool(forKey: "defaultEventsLoaded") {
      logger.debug("Updating next start date. 1")
//      await EventProvider.shared.importEventsFromSeed()
      await checkCoreData()
      await updateNextStartDate(who: "recursion")
    } else {
      logger.debug("Updating next start date. 2")
      let fetchRequest: NSFetchRequest<DailyEvent>
      fetchRequest = DailyEvent.fetchRequest()
      var dailyEventList: [DailyEvent] = []
      do {
        dailyEventList = try viewCloudContext.fetch(fetchRequest)
      } catch {
        logger.error("Couldn't fetch DailyEvent. 😭 \(error.localizedDescription)")
      }
      for dailyEvent in dailyEventList {
        let start = dailyEvent.startTime ?? "00:00"
        let end = dailyEvent.endTime ?? "00:00"
        let result = Dates.getEventDateTimeAndIsToday(start: start, end: end)
        dailyEvent.setValue(result.0, forKey: "nextStartDate")
        if !result.1 {
          dailyEvent.setValue("Tomorrow", forKey: "tomorrow")
        } else {
          dailyEvent.setValue("", forKey: "tomorrow")
        }
        do {
          try viewCloudContext.save()
        } catch {
          logger.error("Could not save nextStartDate. 😭 \(error.localizedDescription)")
        }
      }
      NotificationCenter.default.post(name: .nextStartDateUpdated, object: nil)
    }
  }
  
  func checkCoreData() async {
    logger.debug("dbark - In DataService, checkLocal")
    
    let fetchRequest = NSFetchRequest<DailyEvent>(entityName: "DailyEvent")
    do {
      let dailyEvents = try viewCloudContext.fetch(fetchRequest)
      if dailyEvents.isEmpty {
        if FileManager.default.ubiquityIdentityToken != nil {
          await checkiCloud()
        } else {
          logger.debug("dbark - User not logged in to iCloud")
        }
      } else {
        logger.debug("dbark - Got local data, done")
      }
    } catch {
      logger.debug("dbark - Fetch failed 😭")
    }
  }
  
  func checkiCloud() async {
    logger.debug("dbark - In DataService, checkServer")
    //iCloud Query
    let cloudContainer = CKContainer(identifier: "iCloud.com.dbarkman.YourWeatherLife")
    let privateDatabase = cloudContainer.privateCloudDatabase
    
    let predicate = NSPredicate(value: true)
    let query = CKQuery(recordType: "CD_DailyEvent", predicate: predicate)
    
    do {
      let (queryResults, _) = try await privateDatabase.records(matching: query, resultsLimit: 100)
      logger.debug("Result count: \(queryResults.count)")
    } catch {
      logger.error("Couldn't fetch Daily Events from iCloud. 😭 \(error.localizedDescription)")
      if error.localizedDescription.contains("CD_DailyEvent") || error.localizedDescription.contains("Did not find record type") {
        logger.debug("dbark - Loading seed data")
        await EventProvider.shared.importEventsFromSeed()
      } else {
        logger.debug("Don't need to load events from seed! Need to get from iCloud.")
      }
    }
    
//    let queryOperation = CKQueryOperation(query: query)
//    queryOperation.database = cloudContainer.privateCloudDatabase
//    queryOperation.zoneID = CKRecordZone.ID(zoneName: "com.apple.coredata.cloudkit.zone", ownerName: CKCurrentUserDefaultName)
//    //    queryOperation.desiredKeys = ["CD_typeId", "CD_type"]
//    queryOperation.queuePriority = .veryHigh
//
//    queryOperation.queryResultBlock = await { result in //requires iOS 15
//      logger.debug("dbark - In the queryResultBlock")
//      switch result {
//        case .failure(let error):
//          logger.debug("dbark - Error: \(error.localizedDescription)")
//          if error.localizedDescription.contains("CD_DailyEvent") || error.localizedDescription.contains("Zone does not exist") {
//            logger.debug("dbark - Loading seed data")
////            Task {
//              await EventProvider.shared.importEventsFromSeed()
////            }
//          } else if error.localizedDescription.contains("User rejected a prompt to enter their iCloud account password") {
//            logger.debug("dbark - user needs to sign in")
//            //need to inform the user to sign in again
//          } else {
//            logger.debug("dbark - iCloud query error: \(error.localizedDescription)")
//          }
//        default:
//          logger.debug("dbark - Query operation complete")
//      }
//    }
//    privateDatabase.add(queryOperation)
  }
  
}
