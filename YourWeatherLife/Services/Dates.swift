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
    if format == "HH:mm" {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      dateString = dateFormatter.string(from: now)
      dateFormat = "yyyy-MM-dd"
    }
    let dateTimeFormatter = DateFormatter()
    dateTimeFormatter.dateFormat = dateFormat + format
    let thing = dateString + " " + time
    guard let dateTime = dateTimeFormatter.date(from: thing) else { return now }
    return dateTime
  }
  
  private static func roundTimeDown(time: String) -> String {
    let dateTime = makeDateFromTime(time: time, format: "HH:mm")
    let components = Calendar.current.dateComponents([.hour], from: dateTime)
    let hour = components.hour ?? 0
    var time = "\(hour):00"
    if time.count == 4 {
      time = "0" + time
    }
    return time
  }
  
  static func roundTimeUp(date: Date) -> Date {
    guard let nextHour = Calendar.current.date(byAdding: .hour, value: 1, to: date) else { return Date() }
    let time = makeStringFromDate(date: nextHour, format: "HH:mm")
    let timeRoundedDown = roundTimeDown(time: time)
    return makeDateFromTime(time: timeRoundedDown, format: "HH:mm")
  }
  
  private static func getLastHour(endTime: String, startTimeDate: Date) -> String {
    var lastHour = endTime
    let dateTime = makeDateFromTime(time: endTime, format: "HH:mm")
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
      lastHour = roundTimeDown(time: endTime)
    }
    return lastHour
  }
  
  static func getEventHours(start: String, end: String, startOnly: Bool = false) -> [String] {
    var timeArray: [String] = []
    let now = Date()
    let roundDownStartTime = roundTimeDown(time: start)
    var startTimeDate = makeDateFromTime(time: roundDownStartTime, format: "HH:mm")
    var endTimeDate = makeDateFromTime(time: end, format: "HH:mm")
    if endTimeDate < now {
      endTimeDate = makeFutureDateFromTime(time: end, makeFuture: true)
    }
    let futureStartTimeDate = makeFutureDateFromTime(time: roundDownStartTime)
    if futureStartTimeDate < endTimeDate {
      startTimeDate = futureStartTimeDate
    } else {
      if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: startTimeDate) {
        let timeDifference = Calendar.current.dateComponents([.minute], from: yesterday, to: now)
        if let minutes = timeDifference.minute, minutes < 1440 {
          startTimeDate = yesterday
        }
      }
    }
    while startTimeDate < endTimeDate {
      if let nextHour = Calendar.current.date(byAdding: .hour, value: 1, to: startTimeDate) {
        timeArray.append(makeStringFromDate(date: startTimeDate, format: "yyyy-MM-dd HH:mm"))
        startTimeDate = nextHour
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
    var isToday = Calendar.current.isDateInToday(nextStartDate)
    if !isToday {
      isToday = Calendar.current.isDateInYesterday(nextStartDate)
    }
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
