//
//  TGW_ForecastProvider.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/27/22.
//

import Foundation
import CoreData
import Mixpanel
import OSLog

struct TGW_ForecastProvider {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "TGW_ForecastProvider")
  
  static let shared = TGW_ForecastProvider()
  
  private init() { }
  
  func fetchForecast() async {
    let url = await tgw.shared.getWeatherForecastURL(days: "14")
    if let url = URL(string: url) {
      let urlRequest = URLRequest(url: url)
      let session = URLSession.shared
      
      var encodedData = Data()
      do {
        let (data, response) = try await session.data(for: urlRequest)
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
          Mixpanel.mainInstance().track(event: "Fetched Forecast")
          encodedData = data
        } else {
          return
        }
      } catch {
        logger.error("Failed to received valid response and/or data. 😭 \(error.localizedDescription)")
      }

      do {
        let jsonDecoder = JSONDecoder()
        let forecastDecoder = try jsonDecoder.decode(TGW_ForecastDecoder.self, from: encodedData)
        let forecastDaysArray = forecastDecoder.tgw_forecastDays
        let forecastHoursArray = forecastDecoder.tgw_forecastHours
        
        await importForecastHours(from: forecastHoursArray)
        await importForecastDays(from: forecastDaysArray)
      } catch {
        logger.error("Forecast decode failed. 😭 \(error.localizedDescription)")
      }
    }
  }
  
  private func importForecastHours(from forecastHoursArray: [TGW_ForecastHours]) async {
    guard !forecastHoursArray.isEmpty else { return }
    
    let taskContext = newTaskContext()
    taskContext.name = "importContext"
    taskContext.transactionAuthor = "importForecastHours"
    
    await taskContext.perform {
      let batchInsertRequest = self.newBatchInsertHoursRequest(with: forecastHoursArray)
      do {
        let fetchResult = try taskContext.execute(batchInsertRequest)
        if let batchInsertResult = fetchResult as? NSBatchInsertResult, let success = batchInsertResult.result as? Bool, success {
          return
        }
      } catch {
        logger.error("Couldn't finish batch insert of hours. 😭 \(error.localizedDescription)")
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
      do {
        let fetchResult = try taskContext.execute(batchInsertRequest)
        if let batchInsertResult = fetchResult as? NSBatchInsertResult, let success = batchInsertResult.result as? Bool, success {
          return
        }
      } catch {
        logger.error("Couldn't finish batch insert of days. 😭 \(error.localizedDescription)")
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
