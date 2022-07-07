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
  var tomorrow = ""
  var forecastHours = [HourForecast]()
}
