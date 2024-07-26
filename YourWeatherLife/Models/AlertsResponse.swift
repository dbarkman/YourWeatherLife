//
//  AlertsResponse.swift
//  YourWeatherLife
//
//  Created by David Barkman on 4/12/23.
//

import Foundation

struct AlertsResponse: Codable {
  var alerts: [Alert] = []
  
  enum CodingKeys: String, CodingKey {
    case alerts = "data"
  }
}
