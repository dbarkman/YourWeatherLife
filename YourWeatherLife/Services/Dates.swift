//
//  Dates.swift
//  YourWeatherLife
//
//  Created by David Barkman on 7/1/22.
//

import Foundation
import FirebaseCrashlytics

struct Dates {
  
  static let shared = Dates()
  
  private init() { }
  
  func userFormatDayFirst() -> Bool {
    var dayFirst = false
    if let userFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMdd", options: 0, locale: Locale.current) {
      if userFormat.starts(with: "d") {
        dayFirst = true
      }
    }
    return dayFirst
  }

  private func makeFutureDateFromTime(time: String, date: Date, makeFuture: Bool = true) -> Date {
    var dateString = ""
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateString = dateFormatter.string(from: date)
    let dateTimeFormatter = DateFormatter()
    dateTimeFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    guard let dateTime = dateTimeFormatter.date(from: dateString + " " + time) else { return date }
    if dateTime < date && makeFuture {
      guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: date) else { return date }
      dateString = dateFormatter.string(from: tomorrow)
      guard let tomorrowDateTime = dateTimeFormatter.date(from: dateString + " " + time) else { return date }
      return tomorrowDateTime
    } else {
      return dateTime
    }
  }
  
  func makeStringFromDate(date: Date, format: String) -> String {
    let dateTimeFormatter = DateFormatter()
    dateTimeFormatter.dateFormat = format
    return dateTimeFormatter.string(from: date)
  }

  func makeDateFromString(date: String, format: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    guard let date = dateFormatter.date(from: date) else { return Date() }
    return date
  }

  private func makeDateFromTime(time: String, date: Date, format: String) -> Date {
    let now = date
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

  private func roundTimeDown(time: String) -> String {
    let dateTime = makeDateFromTime(time: time, date: Date(), format: "HH:mm")
    let components = Calendar.current.dateComponents([.hour], from: dateTime)
    let hour = components.hour ?? 0
    var time = "\(hour):00"
    if time.count == 4 {
      time = "0" + time
    }
    return time
  }

  func roundTimeUp(date: Date) -> Date {
    guard let nextHour = Calendar.current.date(byAdding: .hour, value: 1, to: date) else { return Date() }
    let time = makeStringFromDate(date: nextHour, format: "HH:mm")
    let timeRoundedDown = roundTimeDown(time: time)
    return makeDateFromTime(time: timeRoundedDown, date: date, format: "HH:mm")
  }

  func getEventHours(start: String, end: String, date: Date, startOnly: Bool = false) -> [String] {
    var timeArray: [String] = []
    let roundDownStartTime = roundTimeDown(time: start)
    var startTimeDate = makeDateFromTime(time: roundDownStartTime, date: date, format: "HH:mm")
    var endTimeDate = makeDateFromTime(time: end, date: date, format: "HH:mm")
    if endTimeDate < date {
      endTimeDate = makeFutureDateFromTime(time: end, date: date, makeFuture: true)
    }
    let futureStartTimeDate = makeFutureDateFromTime(time: roundDownStartTime, date: date)
    if futureStartTimeDate < endTimeDate {
      startTimeDate = futureStartTimeDate
    } else {
      if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: startTimeDate) {
        let timeDifference = Calendar.current.dateComponents([.minute], from: yesterday, to: date)
        if let minutes = timeDifference.minute, minutes < 1440 {
          startTimeDate = yesterday
        }
      }
    }
    let keysAndValues = ["startTimeDate": startTimeDate, "endTimeDate": endTimeDate] as [String : Any]
    Crashlytics.crashlytics().setCustomKeysAndValues(keysAndValues)
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

  func getEventDateTimeAndIsToday(start: String, end: String, date: Date) -> (String, Bool) {
    let nextStart = getEventHours(start: start, end: end, date: date, startOnly: true)[0]
    let nextStartDate = makeDateFromTime(time: nextStart, date: date, format: "yyyy-MM-dd HH:mm")
    var isToday = Calendar.current.isDateInToday(nextStartDate)
    if !isToday {
      isToday = Calendar.current.isDateInYesterday(nextStartDate)
    }
    return (nextStart, isToday)
  }

  func makeDisplayTimeFromTime(time: String, format: String, full: Bool = false, short: Bool = false) -> String {
    let date = Date()
    let timeDate = makeDateFromTime(time: time, date: date, format: format)
    let formatter = DateFormatter()
    if full {
      formatter.dateFormat = "h:mm a"
      return String(formatter.string(from: timeDate))
    }
    if short {
      formatter.dateFormat = "h a"
      return String(formatter.string(from: timeDate))
    }
    formatter.dateFormat = "h:mma"
    return String(formatter.string(from: timeDate).lowercased().dropLast())
  }

  func getTodayDateString(format: String) -> String {
    let dateTimeFormatter = DateFormatter()
    dateTimeFormatter.dateFormat = format
    let today = dateTimeFormatter.string(from: Date())
    return today
  }
  
  func getThisWeekendDateStrings(format: String) -> [String] {
    let saturdayDate = Calendar.current.nextWeekend(startingAfter: Date())?.start ?? Date()
    let sundayDate = Calendar.current.date(byAdding: .day, value: 1, to: saturdayDate) ?? Date()
    let saturday = Dates.shared.makeStringFromDate(date: saturdayDate, format: format)
    let sunday = Dates.shared.makeStringFromDate(date: sundayDate, format: format)
    return [saturday, sunday]
  }
}
