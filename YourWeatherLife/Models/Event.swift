//
//  Event.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/29/22.
//

import Foundation
import OSLog

struct EventDecoder: Decodable {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "EventDecoder")

  private enum RootCodingKeys: String, CodingKey {
    case data
  }
  
  private(set) var eventList = [Event]()
  
  init(from decoder: Decoder) throws {
    logger.debug("Decoding events init.")
    let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
    logger.debug("Got events root container.")
    var dataContainer = try rootContainer.nestedUnkeyedContainer(forKey: .data)
    logger.debug("Got events data container.")
    while !dataContainer.isAtEnd {
      logger.debug("Decoding an event.")
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
  
  var dictionaryValue: [String: Any] {
    [
      "event": event,
      "startTime": startTime,
      "endTime": endTime,
      "summary": summary
    ]
  }
}
