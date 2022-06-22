//
//  Condition.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/20/22.
//

import Foundation

struct Condition: Decodable, Hashable {
  var text: String
  var icon: String
  var code: Int
}
