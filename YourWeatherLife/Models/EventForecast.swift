//
//  EventForecast.swift
//  YourWeatherLife
//
//  Created by David Barkman on 7/6/22.
//

import Foundation

struct EventForecast: Hashable {
  
  var eventName = ""
  var startTime = ""
  var endTime = ""
  var summary = ""
  var nextStartDate = ""
  var when = ""
  var days = "1234567"
  var forecastHours = [HourForecast]()
  var identifier = ""
}
