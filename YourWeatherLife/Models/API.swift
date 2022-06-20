//
//  API.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/18/22.
//

import Foundation
import CoreData

@objc(API)
class API: NSManagedObject {
  
  @NSManaged var api: String
  @NSManaged var apiKey: String
  @NSManaged var secretKey: String
  @NSManaged var urlBase: String
  @NSManaged var active: Int
  
  func update(from apiProperties: APIProperties) throws {
    let dictionary = apiProperties.dictionaryValue
    guard let newApi = dictionary["api"] as? String,
          let newApiKey = dictionary["apiKey"] as? String,
          let newSecretKey = dictionary["secretKey"] as? String,
          let newUrlBase = dictionary["urlBase"] as? String,
          let newActive = dictionary["active"] as? Int
    else {
      throw YWLError.missingData
    }
    
    api = newApi
    apiKey = newApiKey
    secretKey = newSecretKey
    urlBase = newUrlBase
    active = newActive
  }
  
}

struct APIDecoder: Decodable {
  
  private enum RootCodingKeys: String, CodingKey {
    case data
  }
  
  private(set) var apisList = [APIProperties]()
  
  init(from decoder: Decoder) throws {
    let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
    var dataContainer = try rootContainer.nestedUnkeyedContainer(forKey: .data)
    while !dataContainer.isAtEnd {
      if let apis = try? dataContainer.decode(APIProperties.self) {
        apisList.append(apis)
      }
    }
  }
}

struct APIProperties: Decodable {
  let api: String
  let apiKey: String
  let secretKey: String
  let urlBase: String
  let active: Int
  
  private enum CodingKeys: String, CodingKey {
    case api, apiKey, secretKey, urlBase, active
  }
  
  var dictionaryValue: [String: Any] {
    [
      "api": api,
      "apiKey": apiKey,
      "secretKey": secretKey,
      "urlBase": urlBase,
      "active": active
    ]
  }
}
