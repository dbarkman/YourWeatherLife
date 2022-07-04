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
    if time.count < 6 {
      dateFormatter.dateFormat = "yyyy-MM-dd"
      dateString = dateFormatter.string(from: now)
    }
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
  
  private static func makeStringFromDate(date: Date) -> String {
    let dateTimeFormatter = DateFormatter()
    dateTimeFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    return dateTimeFormatter.string(from: date)
  }
  
  private static func makeDateFromTime(time: String) -> Date {
    let now = Date()
    var dateString = ""
    if time.count < 6 {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      dateString = dateFormatter.string(from: now)
    }
    let dateTimeFormatter = DateFormatter()
    dateTimeFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    guard let dateTime = dateTimeFormatter.date(from: dateString + " " + time) else { return now }
    return dateTime
  }
  
  private static func roundTimeDown(time: String) -> String {
    let dateTime = makeDateFromTime(time: time)
    let components = Calendar.current.dateComponents([.hour], from: dateTime)
    let hour = components.hour ?? 0
    let time = "\(hour):00"
    return time
  }
  
  private static func getLastHour(time: String, startTimeDate: Date) -> String {
    var lastHour = time
    let dateTime = makeDateFromTime(time: time)
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
    let lastHourDate = makeDateFromTime(time: lastHour)
    if lastHourDate < startTimeDate {
      guard let lastHourTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: lastHourDate) else { return time }
      return makeStringFromDate(date: lastHourTomorrow) //returns yyyy-MM-dd HH:mm
    }
    return lastHour //returns HH:mm
  }
  
  static func getEventHours(start: String, end: String, startOnly: Bool = false) -> [String] {
    var timeArray: [String] = []
    let startTime = roundTimeDown(time: start)
    let startTimeDate = makeDateFromTime(time: startTime)
    let lastHour = getLastHour(time: end, startTimeDate: startTimeDate)
    let endTimeDate = makeDateFromTime(time: end)
    let makeFuture = startTimeDate < Date() && endTimeDate > Date() ? false : true
    let startDateTime = makeFutureDateFromTime(time: startTime, makeFuture: makeFuture)
    if startOnly == true { return [makeStringFromDate(date: startDateTime)] }
    let endDateTime = makeFutureDateFromTime(time: lastHour, makeFuture: makeFuture)
    timeArray.append(makeStringFromDate(date: startDateTime))
    var startDateTimeTemp = startDateTime
    while startDateTimeTemp < endDateTime {
      if let nextHour = Calendar.current.date(byAdding: .hour, value: 1, to: startDateTimeTemp) {
        startDateTimeTemp = nextHour
        timeArray.append(makeStringFromDate(date: startDateTimeTemp))
      } else {
        break
      }
    }
    return timeArray
  }
  
  static func makeDisplayTimeFromTime(time: String) -> String {
    let timeDate = makeDateFromTime(time: time)
    let formatter = DateFormatter()
    formatter.dateFormat = "h:mma"
    let displayTime = String(formatter.string(from: timeDate).lowercased().dropLast())
    return displayTime
  }
}
