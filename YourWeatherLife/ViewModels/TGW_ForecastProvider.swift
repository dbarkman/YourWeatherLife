//
//  TGW_ForecastProvider.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/27/22.
//

import Foundation
import CoreData
import OSLog

struct TGW_ForecastProvider {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "TGW_ForecastProvider")
  
  static let shared = TGW_ForecastProvider()
  
  func fetchForecast() async {
    let api = DataService().fetchAPIFromLocalBy(shortName: "tgw")
    let url = await tgw.getWeatherForecastURL(api, days: "14")
    guard !url.isEmpty else { return }
    let urlRequest = URLRequest(url: URL(string: url)!)
    
    let session = URLSession.shared
    guard let (data, response) = try? await session.data(for: urlRequest), let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200
    else {
      logger.error("Failed to received valid response and/or data. 😭")
      return
    }
    
    do {
      let jsonDecoder = JSONDecoder()
      let forecastDecoder = try jsonDecoder.decode(TGW_ForecastDecoder.self, from: data)
      let forecastDaysArray = forecastDecoder.tgw_forecastDays
      let forecastHoursArray = forecastDecoder.tgw_forecastHours

      await importForecastHours(from: forecastHoursArray)
      await importForecastDays(from: forecastDaysArray)
      NotificationCenter.default.post(name: .forecastInsertedEvent, object: nil)
    } catch {
      logger.error("Forecast decode failed. 😭 \(error.localizedDescription)")
    }
  }
  
  private func importForecastHours(from forecastHoursArray: [TGW_ForecastHours]) async {
    guard !forecastHoursArray.isEmpty else { return }
    
    let taskContext = newTaskContext()
    taskContext.name = "importContext"
    taskContext.transactionAuthor = "importForecastHours"
    
    await taskContext.perform {
      let batchInsertRequest = self.newBatchInsertHoursRequest(with: forecastHoursArray)
      if let fetchResult = try? taskContext.execute(batchInsertRequest),
         let batchInsertResult = fetchResult as? NSBatchInsertResult,
         let success = batchInsertResult.result as? Bool, success {
        return
      }
      logger.error("Failed to execute batch insert request of hours. 😭")
    }
  }
  
  private func newBatchInsertHoursRequest(with forecastHoursArray: [TGW_ForecastHours]) -> NSBatchInsertRequest {
    var index = 0
    let total = forecastHoursArray.count
    let batchInsertRequest = NSBatchInsertRequest(entity: TGWForecastHour.entity(), dictionaryHandler: { dictionary in
      guard index < total else { return true }
      dictionary.addEntries(from: forecastHoursArray[index].dictionaryValue)
      index += 1
      return false
    })
    return batchInsertRequest
  }
  
  private func importForecastDays(from forecastDaysArray: [TGW_ForecastDays]) async {
    guard !forecastDaysArray.isEmpty else { return }
    
    let taskContext = newTaskContext()
    taskContext.name = "importContext"
    taskContext.transactionAuthor = "importForecastDays"
    
    await taskContext.perform {
      let batchInsertRequest = self.newBatchInsertDaysRequest(with: forecastDaysArray)
      if let fetchResult = try? taskContext.execute(batchInsertRequest),
         let batchInsertResult = fetchResult as? NSBatchInsertResult,
         let success = batchInsertResult.result as? Bool, success {
        return
      }
      logger.error("Failed to execute batch insert request of days. 😭")
    }
  }
  
  private func newBatchInsertDaysRequest(with forecastDaysArray: [TGW_ForecastDays]) -> NSBatchInsertRequest {
    var index = 0
    let total = forecastDaysArray.count
    let batchInsertRequest = NSBatchInsertRequest(entity: TGWForecastDay.entity(), dictionaryHandler: { dictionary in
      guard index < total else { return true }
      dictionary.addEntries(from: forecastDaysArray[index].dictionaryValue)
      index += 1
      return false
    })
    return batchInsertRequest
  }
  
  private func newTaskContext() -> NSManagedObjectContext {
    let container = LocalPersistenceController.shared.container
    let taskContext = container.newBackgroundContext()
    taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy //adjust this to affect data overwriting, Object = API overwrites local storage, Store = API cannot overwrite local storage
    return taskContext
  }
}
