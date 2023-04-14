//
//  NWSPointsResponse.swift
//  YourWeatherLife
//
//  Created by David Barkman on 4/10/23.
//

import Foundation

struct NWSPointsResponse: Codable, Hashable {
  var properties: PointProperties?
  
  enum CodingKeys: String, CodingKey {
    case properties
  }
}

struct PointProperties: Codable, Hashable {
  var relativeLocation: PropertiesRelativeLocation?
  var county: String?
  
  enum CodingKeys: String, CodingKey {
    case relativeLocation, county
  }
}

struct PropertiesRelativeLocation: Codable, Hashable {
  var properties: RelativeLocationProperties?
  
  enum CodingKeys: String, CodingKey {
    case properties
  }
}

struct RelativeLocationProperties: Codable, Hashable {
  var city: String?
  var state: String?
  
  enum CodingKeys: String, CodingKey {
    case city, state
  }
}
