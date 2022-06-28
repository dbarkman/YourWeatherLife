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
  
  func fetchForecast() async throws {
    let api = DataService().fetchAPIFromLocalBy(shortName: "tgw")
    let url = tgw.getWeatherForecastURL(api, days: "14")
    logger.debug("forecast url: \(url)")
    guard !url.isEmpty else { return }
    let urlRequest = URLRequest(url: URL(string: url)!)
    
    let session = URLSession.shared
    guard let (data, response) = try? await session.data(for: urlRequest), let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200
    else {
      logger.debug("Failed to received valid response and/or data.")
      throw YWLError.missingData
    }
    
    do {
      let jsonDecoder = JSONDecoder()
      let forecastDecoder = try jsonDecoder.decode(TGW_ForecastDecoder.self, from: data)
      let forecastDayArray = forecastDecoder.tgw_forecast.forecastday
      logger.debug("Received \(forecastDayArray.count) days of forecast.")
      let forecastHourArray = forecastDecoder.tgw_forecastHours
      logger.debug("Received \(forecastHourArray.count) hours of forecast.")

//      logger.debug("Start importing data to the store...")
//      try await importAPIs(from: apiList)
//      logger.debug("Finished importing data.")
      logger.debug("Forecast decode worked! 🎉")
    } catch {
      logger.debug("Forecast decode failed 😭")
      print("Forecast decode error: \(error)")
      throw YWLError.wrongDataFormat(error: error)
    }
  }
  
  private func importAPIs(from apisList: [APIProperties]) async throws {
    guard !apisList.isEmpty else { return }
    
    let taskContext = newTaskContext()
    taskContext.name = "importContext"
    taskContext.transactionAuthor = "importAPIs"
    
    try await taskContext.perform {
      let batchInsertRequest = self.newBatchInsertRequest(with: apisList)
      if let fetchResult = try? taskContext.execute(batchInsertRequest),
         let batchInsertResult = fetchResult as? NSBatchInsertResult,
         let success = batchInsertResult.result as? Bool, success {
        return
      }
      logger.debug("Failed to execute batch insert request.")
      throw YWLError.batchInsertError
    }
    logger.debug("Successfully inserted data.")
  }
  
  private func newBatchInsertRequest(with apiList: [APIProperties]) -> NSBatchInsertRequest {
    var index = 0
    let total = apiList.count
    let batchInsertRequest = NSBatchInsertRequest(entity: API.entity(), dictionaryHandler: { dictionary in
      guard index < total else { return true }
      dictionary.addEntries(from: apiList[index].dictionaryValue)
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
