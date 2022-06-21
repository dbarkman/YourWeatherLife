//
//  Current.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/20/22.
//

import Foundation

struct CurrentDecoder: Decodable {
  private enum RootCodingKeys: String, CodingKey {
    case current
  }
  
  private(set) var current: Current
  
  init(from decoder: Decoder) throws {
    let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
    self.current = try rootContainer.decode(Current.self, forKey: .current)
  }
}

struct Current: Decodable, Hashable {
  var temp_c = 0.0
  var condition: Condition
}
