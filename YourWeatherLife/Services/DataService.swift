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
        let now = Date()
        let dayString = dailyEvent.days ?? "123456789" //[2,4,6]
        let days = dayString.compactMap { $0.wholeNumberValue }
        var dates: [Date] = []
        for day in days {
          var components = DateComponents(weekday: day)
          components.hour = Int(start.prefix(2))
          components.minute = Int(start.suffix(2))
          let nextOccurrence = Calendar.current.nextDate(after: now, matching: components, matchingPolicy: .nextTime) ?? now
          dates.append(nextOccurrence)
        }
        dates.sort()
        var nextEventDate = now
        for day in dates {
          nextEventDate = day
          break
        }
        var when = ""
        if Calendar.current.isDateInToday(nextEventDate) {
          when = "Today"
        } else if Calendar.current.isDateInTomorrow(nextEventDate) {
          when = "Tomorrow"
        } else {
          when = Dates.makeStringFromDate(date: nextEventDate, format: "EEEE")
        }
        let nextStartDate = Dates.makeStringFromDate(date: nextEventDate, format: "yyyy-MM-dd HH:mm")
        dailyEvent.setValue(nextStartDate, forKey: "nextStartDate")
        dailyEvent.setValue(when, forKey: "when")

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
        let cloudKitManager = await CloudKitManager()
        let accountStatus = cloudKitManager.accountStatus

        if FileManager.default.ubiquityIdentityToken != nil && accountStatus == .available {
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
