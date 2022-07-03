//
//  Event.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/29/22.
//

import Foundation

struct Event: Identifiable {
  
  var id: UUID
  var event: String
  var startTime: String
  var endTime: String
  var summary: String
}
