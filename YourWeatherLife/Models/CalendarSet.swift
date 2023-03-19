//
//  CalendarSet.swift
//  YourWeatherLife
//
//  Created by David Barkman on 1/19/23.
//

import Foundation
import EventKit

struct CalendarSet: Identifiable {
  var id = UUID()
  var title: String
  var calendars: [EKCalendar]
}
