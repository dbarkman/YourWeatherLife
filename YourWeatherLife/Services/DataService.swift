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
      await EventProvider.shared.importEventsFromSeed()
      await updateNextStartDate()
    } else {
      logger.debug("Updating next start date.")
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
}
