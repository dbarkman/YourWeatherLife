//
//  API.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/18/22.
//

import Foundation
import CoreData
import OSLog

@objc(API)
class API: NSManagedObject {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "API")

  @NSManaged var api: String
  @NSManaged var shortName: String
  @NSManaged var priority: Int
  @NSManaged var apiKey: String
  @NSManaged var secretKey: String
  @NSManaged var urlBase: String
  @NSManaged var active: Int
  
  private func update(from apiProperties: APIProperties) throws {
    let dictionary = apiProperties.dictionaryValue
    guard let newApi = dictionary["api"] as? String,
          let newShortName = dictionary["shortName"] as? String,
          let newPriority = dictionary["priority"] as? Int,
          let newApiKey = dictionary["apiKey"] as? String,
          let newSecretKey = dictionary["secretKey"] as? String,
          let newUrlBase = dictionary["urlBase"] as? String,
          let newActive = dictionary["active"] as? Int
    else {
      throw YWLError.missingData
    }
    
    api = newApi
    shortName = newShortName
    priority = newPriority
    apiKey = newApiKey
    secretKey = newSecretKey
    urlBase = newUrlBase
    active = newActive
  }
  
}

struct APIDecoder: Decodable {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "APIDecoder")
  
  private enum RootCodingKeys: String, CodingKey {
    case data
  }
  
  private(set) var apisList = [APIProperties]()
  
  init(from decoder: Decoder) throws {
    let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
    var dataContainer = try rootContainer.nestedUnkeyedContainer(forKey: .data)
    while !dataContainer.isAtEnd {
      do {
        let apis = try dataContainer.decode(APIProperties.self)
        apisList.append(apis)
      } catch {
        logger.error("Couldn't decode APIs data container. 😭 \(error.localizedDescription)")
      }
    }
  }
}

struct APIProperties: Decodable {
  let api: String
  let shortName: String
  let priority: Int
  let apiKey: String
  let secretKey: String
  let urlBase: String
  let active: Int
  
  private enum CodingKeys: String, CodingKey {
    case api, shortName, priority, apiKey, secretKey, urlBase, active
  }
  
  var dictionaryValue: [String: Any] {
    [
      "api": api,
      "shortName": shortName,
      "priority": priority,
      "apiKey": apiKey,
      "secretKey": secretKey,
      "urlBase": urlBase,
      "active": active
    ]
  }
}
