//
//  Event.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/29/22.
//

import Foundation
import OSLog

struct EventDecoder: Decodable {
  
//  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "EventDecoder")

  private enum RootCodingKeys: String, CodingKey {
    case data
  }
  
  private(set) var eventList = [Event]()
  
  init(from decoder: Decoder) throws {
    let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
    var dataContainer = try rootContainer.nestedUnkeyedContainer(forKey: .data)
    while !dataContainer.isAtEnd {
      if let event = try? dataContainer.decode(Event.self) {
        eventList.append(event)
      }
    }
  }
}

struct Event: Decodable, Hashable {
  
  var event: String
  var startTime: String
  var endTime: String
  var summary: String
  var nextStartDate: String
  
  var dictionaryValue: [String: Any] {
    [
      "event": event,
      "startTime": startTime,
      "endTime": endTime,
      "summary": summary,
      "nextStartDate": nextStartDate
    ]
  }
}
