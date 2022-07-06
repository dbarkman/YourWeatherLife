//
//  WindDirection.swift
//  YourWeatherLife
//
//  Created by David Barkman on 7/6/22.
//

import Foundation

enum WindDirection: String {
  case north = "North", east = "East", south = "South", west = "West"
  case northEast = "Northeast", northWest = "Northwest", southEast = "Southeast", southWest = "Southwest"
  case northNorthEast = "North-Northeast", northNorthWest = "North-NorthWest", southSouthEast = "South-Southeast", southSouthWest = "South-Southwest"
  case westNorthWest = "West-Northwest", westSouthWest = "West-Southwest", eastNorthEast = "East-NorthEast", eastSouthEast = "East-Southeast"
}

enum WindDirectionAbbreviated: String {
case north = "N", east = "E", south = "S", west = "W"
case northEast = "NE", northWest = "NW", southEast = "SE", southWest = "SW"
case northNorthEast = "NNE", northNorthWest = "NNW", southSouthEast = "SSE", southSouthWest = "SSW"
case westNorthWest = "West-Northwest", westSouthWest = "WSW", eastNorthEast = "ENE", eastSouthEast = "ESE"
}
