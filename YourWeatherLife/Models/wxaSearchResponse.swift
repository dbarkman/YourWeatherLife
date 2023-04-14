//
//  WxaSearchResponse.swift
//  YourWeatherLife
//
//  Created by David Barkman on 4/10/23.
//

import Foundation

struct WxaSearchResponse: Codable, Hashable {
  var searchResponse: [SearchResponse]?
}

struct SearchResponse: Codable, Hashable {
  var lat: Double?
  var long: Double?
  
  enum CodingKeys: String, CodingKey {
    case lat
    case long = "lon"
  }
}
