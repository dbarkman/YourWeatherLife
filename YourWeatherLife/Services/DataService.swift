//
//  DataService.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/21/22.
//

import Foundation
import CoreData
import CloudKit
import Mixpanel
import OSLog

struct DataService {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "DataService")
  
  static let shared = DataService()
  
  var viewCloudContext = CloudPersistenceController.shared.container.viewContext
  
  private init() { }
  
  private func fetchAPIsFromCloud() async {
    await APIsProvider.shared.fetchAPIs()
  }
  
  private func fetchPrimaryAPIFromLocal () async -> API {
    let api = API()
    api.apiKey = APISettings.shared.fetchAPISettings().tgwApiKey
    api.urlBase = APISettings.shared.fetchAPISettings().tgwUrlBase
    return api
  }
  
  private func fetchAPIFromLocalBy(shortName: String) -> API {
    let api = API()
    api.apiKey = APISettings.shared.fetchAPISettings().tgwApiKey
    api.urlBase = APISettings.shared.fetchAPISettings().tgwUrlBase
    return api
  }
  
  func updateNextStartDate() async {
    logger.debug("Updating Next Start Dates")
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
        let now = Date()
        let today = Calendar.current.component(.weekday, from: now)
        let dayString = dailyEvent.days ?? "1234567" //[2,4,6]
        let days = dayString.compactMap { $0.wholeNumberValue }
        var dates: [Date] = []
        for day in days {
          var components = DateComponents(weekday: day)
          components.hour = Int(start.prefix(2))
          components.minute = Int(start.suffix(2))
          let weekday = components.weekday ?? 1
          if today == weekday {
            let isToday = Dates.shared.getEventDateTimeAndIsToday(start: start, end: end, date: now)
            if isToday.1 {
              dates.removeAll()
              let todayDate = Dates.shared.makeDateFromString(date: isToday.0, format: "yyyy-MM-dd HH:mm")
              dates.append(todayDate)
              break
            }
          }
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
          when = Dates.shared.makeStringFromDate(date: nextEventDate, format: "EEEE")
        }
        let nextStartDate = Dates.shared.makeStringFromDate(date: nextEventDate, format: "yyyy-MM-dd HH:mm")
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
  
  private func checkCoreData() async {
    logger.debug("dbark - In DataService, checkLocal")
    let fetchRequest = NSFetchRequest<DailyEvent>(entityName: "DailyEvent")
    do {
      let dailyEvents = try viewCloudContext.fetch(fetchRequest)
      if dailyEvents.isEmpty {
        let accountStatus = await CloudKitManager.shared.requestAccountStatus()
        if FileManager.default.ubiquityIdentityToken != nil && accountStatus == .available {
          await checkiCloud()
        } else {
          Mixpanel.mainInstance().track(event: "userNotLoggedIniCloud")
          UserDefaults.standard.set(true, forKey: "userNotLoggedIniCloud")
        }
      } else {
        UserDefaults.standard.set(true, forKey: "defaultEventsLoaded")
      }
    } catch {
      Mixpanel.mainInstance().track(event: "initialFetchFailed")
      UserDefaults.standard.set(true, forKey: "initialFetchFailed")
    }
  }
  
  private func checkiCloud() async {
    logger.debug("dbark - In DataService, checkServer")
    let cloudContainer = CKContainer(identifier: "iCloud.com.dbarkman.YourWeatherLife")
    let privateDatabase = cloudContainer.privateCloudDatabase
    let predicate = NSPredicate(value: true)
    let query = CKQuery(recordType: "CD_DailyEvent", predicate: predicate)
    do {
      let (result, _) = try await privateDatabase.records(matching: query, resultsLimit: 100)
      if result.count > 0 {
        logger.debug("Events in iCloud")
        UserDefaults.standard.set(true, forKey: "defaultEventsLoaded")
      } else {
        logger.debug("No events in iCloud, loading from seed")
        await EventProvider.shared.importEventsFromSeed()
      }
    } catch {
      if error.localizedDescription.contains("CD_DailyEvent") || error.localizedDescription.contains("Did not find record type") {
        logger.debug("Events not yet setup in iCloud, loading from seed")
        await EventProvider.shared.importEventsFromSeed()
      } else {
        logger.debug("Events in iCloud, nothing to do")
        UserDefaults.standard.set(true, forKey: "defaultEventsLoaded")
      }
    }
  }
}
