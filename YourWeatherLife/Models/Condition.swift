//
//  Condition.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/20/22.
//

import Foundation

struct ConditionDecoder: Decodable {
  private enum RootCodingKeys: String, CodingKey {
    case condition
  }
  
  private(set) var condition: Condition
  
  init(from decoder: Decoder) throws {
    let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
    self.condition = try rootContainer.decode(Condition.self, forKey: .condition)
  }
}

struct Condition: Decodable, Hashable {
  var text: String
  var icon: String
  var code: Int
}
