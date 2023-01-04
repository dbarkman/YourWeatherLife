//
//  APIsProvider.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/18/22.
//

import Foundation
import CoreData
import OSLog

struct APIsProvider {

  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "APIsProvider")
  
  static let shared = APIsProvider()
  
  private init() { }
  
  func fetchAPIs() async {
    let apiKey = APISettings.shared.fetchAPISettings().apiKey
    let secretKey = APISettings.shared.fetchAPISettings().secretKey
    let urlBase = APISettings.shared.fetchAPISettings().urlBase
    let apisEndpoint = APISettings.shared.fetchAPISettings().apisEndpoint
    let signature = CryptoUtilities.shared.signRequest(input: apiKey, secretKey: secretKey)
    
    let urlString = urlBase + apisEndpoint
    logger.debug("url 1: \(urlString)")
    if let apisURL = URL(string: urlString) {
      var urlRequest = URLRequest(url: apisURL)
      urlRequest.setValue(apiKey, forHTTPHeaderField: "apiKey")
      urlRequest.setValue(signature, forHTTPHeaderField: "signature")
      
      let session = URLSession.shared
      do {
        let (data, response) = try await session.data(for: urlRequest)
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
          await decodeAPIs(data: data)
        } else {
          return
        }
      } catch {
        logger.error("Failed to received valid response and/or data. 😭 \(error.localizedDescription)")
      }
    }
  }
  
  private func decodeAPIs(data: Data) async {
    do {
      let jsonDecoder = JSONDecoder()
      let apiDecoder = try jsonDecoder.decode(APIDecoder.self, from: data)
      let apiList = apiDecoder.apisList
      await importAPIs(from: apiList)
    } catch {
      logger.error("Failed to decode data when fetching APIs. 😭 \(error.localizedDescription)")
    }
  }
  
  private func importAPIs(from apisList: [APIProperties]) async {
    guard !apisList.isEmpty else { return }
    
    let taskContext = newTaskContext()
    taskContext.name = "importContext"
    taskContext.transactionAuthor = "importAPIs"
    
    await taskContext.perform {
      let batchInsertRequest = self.newBatchInsertRequest(with: apisList)
      do {
        let fetchResult = try taskContext.execute(batchInsertRequest)
        if let batchInsertResult = fetchResult as? NSBatchInsertResult, let success = batchInsertResult.result as? Bool, success {
          return
        }
      } catch {
        logger.error("Couldn't finish batch insert of APIs. 😭 \(error.localizedDescription)")
      }
      logger.error("Failed to execute batch insert request. 😭")
    }
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
