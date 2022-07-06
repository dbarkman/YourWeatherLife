//
//  Today.swift
//  YourWeatherLife
//
//  Created by David Barkman on 7/4/22.
//

import Foundation

struct Today: Hashable {
  
  var precipitation = false
  var precipitationType = ""
  var precipitationPercent = ""
  var coldestTemp = ""
  var coldestTime = ""
  var warmestTemp = ""
  var warmestTime = ""
  var sunriseTemp = ""
  var sunriseTime = ""
  var sunsetTemp = ""
  var sunsetTime = ""
  var dayOfWeek = ""
  var hours: [HourForecast]?
}
