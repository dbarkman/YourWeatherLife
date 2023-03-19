//
//  AsyncAPI.swift
//  YourWeatherLife
//
//  Created by David Barkman on 3/19/23.
//

import Foundation
import Mixpanel
import OSLog

struct AsyncAPI {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "AsyncAPI")
  
  static let shared = AsyncAPI()
  
  private init() { }
  
  //future notifications framework
  func saveToken(token: String, debug: Int) async {
    let distinctId = UUID().uuidString
    UserDefaults.standard.set(distinctId, forKey: "distinctId")
    Mixpanel.mainInstance().identify(distinctId: distinctId)
    Mixpanel.mainInstance().people.set(properties: ["$name":distinctId])
  }
  
}
