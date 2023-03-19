//
//  EventSet.swift
//  YourWeatherLife
//
//  Created by David Barkman on 1/25/23.
//

import UIKit

struct EventSet: Identifiable {
  var id = UUID()
  var calendar: String
  var color: CGColor
  var events: [String]
}
