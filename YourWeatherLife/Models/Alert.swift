//
//  Alert.swift
//  YourWeatherLife
//
//  Created by David Barkman on 4/12/23.
//

import Foundation

struct Alert: Codable, Equatable, Hashable, Identifiable {
  var id: String?
  var type: String?
  var geometryType: String?
  var geometryCoordinates: [[[Double]]]?
  var areaDesc: String?
  var affectedZones: [String]?
  var sent: String?
  var effective: String?
  var onset: String?
  var expires: String?
  var ends: String?
  var status: String?
  var messageType: String?
  var category: String?
  var severity: String?
  var certainty: String?
  var urgency: String?
  var event: String?
  var sender: String?
  var senderName: String?
  var headline: String?
  var description: String?
  var instruction: String?
  var response: String?
  var AWIPSidentifier: [String]?
  var WMOidentifier: [String]?
  var windThreat: [String]?
  var hailThreat: [String]?
  var maxHailSize: [String]?
  var tornadoDetection: [String]?
  var waterspoutDetection: [String]?
  var flashFloodDetection: [String]?
  var flashFloodDamageThreat: [String]?
  var eventMotionDescription: [String]?
  var VTEC: [String]?
  var EASORG: [String]?
  var BLOCKCHANNEL: [String]?
  var CMAMtext: [String]?
  var CMAMlongtext: [String]?
  var NWSheadline: [String]?
  var WEAHandling: [String]?
  var eventEndingTime: String?
  
  enum CodingKeys: String, CodingKey {
    case id, type, geometryType, geometryCoordinates, areaDesc, affectedZones, sent, effective, onset, expires, ends, status, messageType, category, severity, certainty, urgency, event, sender, senderName, headline, description, instruction, response, AWIPSidentifier, WMOidentifier, windThreat, hailThreat, maxHailSize, tornadoDetection, waterspoutDetection, flashFloodDetection, flashFloodDamageThreat, eventMotionDescription, VTEC, EASORG, BLOCKCHANNEL, CMAMtext, CMAMlongtext, NWSheadline, WEAHandling, eventEndingTime
  }
}
