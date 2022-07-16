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
  
  func updateNextStartDate() async {
    if !UserDefaults.standard.bool(forKey: "defaultEventsLoaded") {
      await checkCoreData()
      if UserDefaults.standard.bool(forKey: "userNotLoggedIniCloud") || UserDefaults.standard.bool(forKey: "initialFetchFailed") { return }
      await updateNextStartDate()
    } else {
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
          UserDefaults.standard.set(true, forKey: "userNotLoggedIniCloud")
        }
      } else {
        UserDefaults.standard.set(true, forKey: "defaultEventsLoaded")
      }
    } catch {
      UserDefaults.standard.set(true, forKey: "initialFetchFailed")
    }
  }
  
  func checkiCloud() async {
    logger.debug("dbark - In DataService, checkServer")
    let cloudContainer = CKContainer(identifier: "iCloud.com.dbarkman.YourWeatherLife")
    let privateDatabase = cloudContainer.privateCloudDatabase
    let predicate = NSPredicate(value: true)
    let query = CKQuery(recordType: "CD_DailyEvent", predicate: predicate)
    do {
      let (_, _) = try await privateDatabase.records(matching: query, resultsLimit: 100)
      UserDefaults.standard.set(true, forKey: "defaultEventsLoaded")
    } catch {
      if error.localizedDescription.contains("CD_DailyEvent") || error.localizedDescription.contains("Did not find record type") {
        await EventProvider.shared.importEventsFromSeed()
      } else {
        UserDefaults.standard.set(true, forKey: "defaultEventsLoaded")
      }
    }
  }
  
}
