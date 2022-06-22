//
//  CurrentConditions.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/21/22.
//

import Foundation

struct CurrentConditionsDecoder: Decodable {
  private enum RootCodingKeys: String, CodingKey {
    case location, current
  }
  
  private(set) var location: Location
  private(set) var current: Current

  init(from decoder: Decoder) throws {
    let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
    self.location = try rootContainer.decode(Location.self, forKey: .location)
    self.current = try rootContainer.decode(Current.self, forKey: .current)
    self.current.displayTemp = Formatters.format(temp: self.current.temp_c, from: .celsius)
  }
}

struct CurrentConditions: Decodable, Hashable {
  var location: Location
  var current: Current
}
