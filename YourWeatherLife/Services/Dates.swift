//
//  Dates.swift
//  YourWeatherLife
//
//  Created by David Barkman on 7/1/22.
//

import Foundation

struct Dates {

  private static func makeFutureDateFromTime(time: String, makeFuture: Bool = true) -> Date {
    let now = Date()
    var dateString = ""
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateString = dateFormatter.string(from: now)
    let dateTimeFormatter = DateFormatter()
    dateTimeFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    guard let dateTime = dateTimeFormatter.date(from: dateString + " " + time) else { return now }
    if dateTime < now && makeFuture {
      guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now) else { return now }
      dateString = dateFormatter.string(from: tomorrow)
      guard let tomorrowDateTime = dateTimeFormatter.date(from: dateString + " " + time) else { return now }
      return tomorrowDateTime
    } else {
      return dateTime
    }
  }
  
  static func makeStringFromDate(date: Date, format: String) -> String {
    let dateTimeFormatter = DateFormatter()
    dateTimeFormatter.dateFormat = format
    return dateTimeFormatter.string(from: date)
  }
  
  static func makeDateFromTime(time: String, format: String) -> Date {
    let now = Date()
    var dateFormat = ""
    var dateString = ""
    if !format.contains("yyyy-MM-dd") {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      dateString = dateFormatter.string(from: now)
      dateFormat = "yyyy-MM-dd"
    }
    let dateTimeFormatter = DateFormatter()
    dateTimeFormatter.dateFormat = dateFormat + format
    guard let dateTime = dateTimeFormatter.date(from: dateString + " " + time) else { return now }
    return dateTime
  }
  
  private static func roundTimeDown(time: String) -> String {
    let dateTime = makeDateFromTime(time: time, format: "HH:mm")
    let components = Calendar.current.dateComponents([.hour], from: dateTime)
    let hour = components.hour ?? 0
    let time = "\(hour):00"
    return time
  }
  
  private static func getLastHour(time: String, startTimeDate: Date) -> String {
    var lastHour = time
    let dateTime = makeDateFromTime(time: time, format: "HH:mm")
    let components = Calendar.current.dateComponents([.hour, .minute], from: dateTime)
    if components.minute == 0 {
      let hour = components.hour ?? 0
      let roundDownHour = hour - 1
      if roundDownHour < 0 {
        lastHour = "23:00"
      } else {
        lastHour = "\(roundDownHour):00"
      }
    } else {
      lastHour = roundTimeDown(time: time)
    }
    let lastHourDate = makeDateFromTime(time: lastHour, format: "HH:mm")
    if lastHourDate < startTimeDate {
      guard let lastHourTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: lastHourDate) else { return time }
      return makeStringFromDate(date: lastHourTomorrow, format: "yyyy-MM-dd HH:mm") //returns yyyy-MM-dd HH:mm
    }
    return lastHour //returns HH:mm
  }
  
  static func getEventHours(start: String, end: String, startOnly: Bool = false) -> [String] {
    var timeArray: [String] = []
    let startTime = roundTimeDown(time: start)
    let startTimeDate = makeDateFromTime(time: startTime, format: "HH:mm")
    let lastHour = getLastHour(time: end, startTimeDate: startTimeDate)
    var endTimeDate = makeDateFromTime(time: end, format: "HH:mm")
    if startTimeDate > endTimeDate { endTimeDate = makeFutureDateFromTime(time: end) }
    let makeFuture = startTimeDate < Date() && endTimeDate > Date() ? false : true
    let startDateTime = makeFutureDateFromTime(time: startTime, makeFuture: makeFuture)
    if startOnly == true { return [makeStringFromDate(date: startDateTime, format: "yyyy-MM-dd HH:mm")] }
    let endDateTime = makeFutureDateFromTime(time: lastHour, makeFuture: makeFuture)
    timeArray.append(makeStringFromDate(date: startDateTime, format: "yyyy-MM-dd HH:mm"))
    var startDateTimeTemp = startDateTime
    while startDateTimeTemp < endDateTime {
      if let nextHour = Calendar.current.date(byAdding: .hour, value: 1, to: startDateTimeTemp) {
        startDateTimeTemp = nextHour
        timeArray.append(makeStringFromDate(date: startDateTimeTemp, format: "yyyy-MM-dd HH:mm"))
      } else {
        break
      }
    }
    return timeArray
  }
  
  static func makeDisplayTimeFromTime(time: String, format: String, full: Bool = false) -> String {
    let timeDate = makeDateFromTime(time: time, format: format)
    let formatter = DateFormatter()
    if full {
      formatter.dateFormat = "h:mm a"
      return String(formatter.string(from: timeDate))
    }
    formatter.dateFormat = "h:mma"
    return String(formatter.string(from: timeDate).lowercased().dropLast())
  }

  static func getEventDateTimeAndIsToday(start: String, end: String) -> (String, Bool) {
    let nextStart = getEventHours(start: start, end: end, startOnly: true)[0]
    let nextStartDate = makeDateFromTime(time: nextStart, format: "yyyy-MM-dd HH:mm")
    let isToday = Calendar.current.isDateInToday(nextStartDate)
    return (nextStart, isToday)
  }
  
  static func getTodayDateString(format: String) -> String {
    let dateTimeFormatter = DateFormatter()
    dateTimeFormatter.dateFormat = format
    let today = dateTimeFormatter.string(from: Date())
    return today
  }
  
  static func getThisWeekendDateStrings(format: String) -> [String] {
    let saturdayDate = Calendar.current.nextWeekend(startingAfter: Date())?.start ?? Date()
    let sundayDate = Calendar.current.date(byAdding: .day, value: 1, to: saturdayDate) ?? Date()
    let saturday = Dates.makeStringFromDate(date: saturdayDate, format: format)
    let sunday = Dates.makeStringFromDate(date: sundayDate, format: format)
    return [saturday, sunday]
  }
}
