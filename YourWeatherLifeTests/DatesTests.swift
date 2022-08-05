//
//  DatesTests.swift
//  YourWeatherLifeTests
//
//  Created by David Barkman on 7/29/22.
//

import XCTest
@testable import YourWeatherLife

class DatesTests: XCTestCase {
  
  var sut: Dates!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    sut = Dates.shared
  }
  
  override func tearDownWithError() throws {
    sut = nil
    try super.tearDownWithError()
  }
  
  func testMakeStringFromDate() throws {
    // given
    let format1 = "yyyy-MM-dd HH:mm"
    let format2 = "h:mma"
    let date1 = sut.makeDateFromString(date: "2000-07-15 12:00", format: format1)
    let date2 = sut.makeDateFromString(date: "11:30p", format: format2)
    
    // when
    let result1 = sut.makeStringFromDate(date: date1, format: format1)
    let result2 = sut.makeStringFromDate(date: date2, format: format2)
    
    // then
    XCTAssertEqual(result1, "2000-07-15 12:00", "Make string 2000-07-15 12:00 from date, failed.")
    XCTAssertEqual(result2, "11:30PM", "Make string 11:30p from date, failed.")
  }
  
  func testMakeDateFromString() throws {
    // given
    let format = "yyyy-MM-dd HH:mm"
    let dateString = "2000-07-15 12:00"
    let date = sut.makeDateFromString(date: dateString, format: format)
    
    // when
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    guard let dateResult = dateFormatter.date(from: dateString) else {
      XCTFail()
      return
    }
    
    // then
    XCTAssertEqual(date, dateResult, "Make date from string 2000-07-15 12:00, failed.")
  }
  
  func testRoundUpTime() throws {
    //given
    let format = "yyyy-MM-dd HH:mm"
    let date = sut.makeDateFromString(date: "2000-07-15 12:00", format: format)
    
    //when
    let result = sut.roundTimeUp(date: date)
    let finalResult = sut.makeStringFromDate(date: result, format: format)
    
    //then
    XCTAssertEqual(finalResult, "2000-07-15 13:00", "Round up time from 12:00, failed.")
  }
  
  func testGetEventHours() throws {
    //given
    let format = "yyyy-MM-dd HH:mm"
    let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: Date())
    let hour = dateComponents.hour ?? 0
    let minute = dateComponents.minute ?? 0
    let hourString = "\(hour)"
    let minuteString = "\(minute)"
    let date = sut.makeDateFromString(date: "2000-07-15 \(hourString):\(minuteString)", format: format)
    
    //when
    let result1 = sut.getEventHours(start: "06:00", end: "08:00", date: date)
    let result2 = sut.getEventHours(start: "12:00", end: "14:00", date: date)
    let result3 = sut.getEventHours(start: "18:00", end: "20:00", date: date)
    let result4 = sut.getEventHours(start: "07:30", end: "09:30", date: date)
    let result5 = sut.getEventHours(start: "11:00", end: "12:00", date: date)
    let result6 = sut.getEventHours(start: "22:00", end: "02:00", date: date)
    let result7 = sut.getEventHours(start: "00:00", end: "02:00", date: date)
    let countResult = sut.getEventHours(start: "02:00", end: "02:00", date: date).count
    
    //then
    if hour < 8 {
      XCTAssertEqual(result1, ["2000-07-15 06:00", "2000-07-15 07:00"], "Get event hours 6a-8a, before 8a, failed")
    } else {
      XCTAssertEqual(result1, ["2000-07-16 06:00", "2000-07-16 07:00"], "Get event hours 6a-8a, after 8a, failed")
    }
    if hour < 14 {
      XCTAssertEqual(result2, ["2000-07-15 12:00", "2000-07-15 13:00"], "Get event hours 12p-2p, before 2p, failed")
    } else {
      XCTAssertEqual(result2, ["2000-07-16 12:00", "2000-07-16 13:00"], "Get event hours 12p-2p, after 2p, failed")
    }
    if hour < 20 {
      XCTAssertEqual(result3, ["2000-07-15 18:00", "2000-07-15 19:00"], "Get event hours 6p-8p, before 8p, failed")
    } else {
      XCTAssertEqual(result3, ["2000-07-16 18:00", "2000-07-16 19:00"], "Get event hours 6p-8p, after 8p, failed")
    }
    if hour == 9 {
      if minute < 30 {
        XCTAssertEqual(result4, ["2000-07-15 07:00", "2000-07-15 08:00", "2000-07-15 09:00"], "Get event hours 7:30a-9:30a, between 9a and 9:30a, failed")
      }
    }
    if hour < 9 {
      XCTAssertEqual(result4, ["2000-07-15 07:00", "2000-07-15 08:00", "2000-07-15 09:00"], "Get event hours 7:30a-9:30a, before 9a, failed")
    } else if hour >= 9 && minute >= 30 {
      XCTAssertEqual(result4, ["2000-07-16 07:00", "2000-07-16 08:00", "2000-07-16 09:00"], "Get event hours 7:30a-9:30a, after 9:30a, failed")
    }
    if hour < 12 {
      XCTAssertEqual(result5, ["2000-07-15 11:00"], "Get event hours 11a-12p, before 12p, failed")
    } else {
      XCTAssertEqual(result5, ["2000-07-16 11:00"], "Get event hours 11a-12p, after 12p, failed")
    }
    if hour < 2 {
      XCTAssertEqual(result6, ["2000-07-14 22:00", "2000-07-14 23:00", "2000-07-15 00:00", "2000-07-15 01:00"], "Get event hours 10p-2a, before 2a, failed")
    } else {
      XCTAssertEqual(result6, ["2000-07-15 22:00", "2000-07-15 23:00", "2000-07-16 00:00", "2000-07-16 01:00"], "Get event hours 10p-2a, after 2a, failed")
    }
    if hour < 2 {
      XCTAssertEqual(result7, ["2000-07-15 00:00", "2000-07-15 01:00"], "Get event hours 12a-2a, before 2a, failed")
    } else {
      XCTAssertEqual(result7, ["2000-07-16 00:00", "2000-07-16 01:00"], "Get event hours 12a-2a, after 2a, failed")
    }
    XCTAssertEqual(countResult, 24, "Get event hour count for 2a-2a, failed")
  }
  
  func testGetEventDateTimeAndIsToday() {
    //given
    let today = Date()
    let dateFormat = "yyyy-MM-dd"
    let todayString = sut.makeStringFromDate(date: today, format: dateFormat)
    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today
    let tomorrowString = sut.makeStringFromDate(date: tomorrow, format: dateFormat)
    let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: today)
    let hour = dateComponents.hour ?? 0
    
    //when
    let hour1 = "06:00"
    let result1 = sut.getEventDateTimeAndIsToday(start: hour1, end: "08:00", date: today)
    let eventStartdate1 = result1.0
    let isToday1 = result1.1
    let hour2 = "12:00"
    let result2 = sut.getEventDateTimeAndIsToday(start: hour2, end: "14:00", date: today)
    let eventStartdate2 = result2.0
    let isToday2 = result2.1
    let hour3 = "18:00"
    let result3 = sut.getEventDateTimeAndIsToday(start: hour3, end: "20:00", date: today)
    let eventStartdate3 = result3.0
    let isToday3 = result3.1
    
    //then
    if hour < 8 {
      XCTAssertEqual(eventStartdate1, todayString + " " + hour1, "Get event date time and is today for 6a-8a, before 8a, failed.")
      XCTAssertTrue(isToday1)
    } else {
      XCTAssertEqual(eventStartdate1, tomorrowString + " " + hour1, "Get event date time and is today for 6a-8a, after 8a, failed.")
      XCTAssertFalse(isToday1)
    }
    if hour < 14 {
      XCTAssertEqual(eventStartdate2, todayString + " " + hour2, "Get event date time and is today for 12p-2p, before 2p, failed.")
      XCTAssertTrue(isToday2)
    } else {
      XCTAssertEqual(eventStartdate2, tomorrowString + " " + hour2, "Get event date time and is today for 12p-2p, after 2p, failed.")
      XCTAssertFalse(isToday2)
    }
    if hour < 20 {
      XCTAssertEqual(eventStartdate3, todayString + " " + hour3, "Get event date time and is today for 6p-8p, before 8p, failed.")
      XCTAssertTrue(isToday3)
    } else {
      XCTAssertEqual(eventStartdate3, tomorrowString + " " + hour3, "Get event date time and is today for 6p-8p, after 8p, failed.")
      XCTAssertFalse(isToday3)
    }
  }
  
  func testMakeDisplayTimeFromTime() {
    //given
    //when
    let result1 = sut.makeDisplayTimeFromTime(time: "07:00", format: "HH:mm")
    let result2 = sut.makeDisplayTimeFromTime(time: "7:00 PM", format: "hh:mm aa")
    let result3 = sut.makeDisplayTimeFromTime(time: "2022-07-05 07:00", format: "yyyy-MM-dd HH:mm")
    let result4 = sut.makeDisplayTimeFromTime(time: "2022-07-05 14:00", format: "yyyy-MM-dd HH:mm")
    let result5 = sut.makeDisplayTimeFromTime(time: "07:00", format: "HH:mm", full: true)
    let result6 = sut.makeDisplayTimeFromTime(time: "07:00", format: "HH:mm", short: true)

    //then
    XCTAssertEqual(result1, "7:00a", "Make display time from time for 07:00, failed.")
    XCTAssertEqual(result2, "7:00p", "Make display time from time for 7:00 PM, failed.")
    XCTAssertEqual(result3, "7:00a", "Make display time from time for 2022-07-05 07:00, failed.")
    XCTAssertEqual(result4, "2:00p", "Make display time from time for 2022-07-05 14:00, failed.")
    XCTAssertEqual(result5, "7:00 AM", "Make display time from time for 07:00, failed.")
    XCTAssertEqual(result6, "7 AM", "Make display time from time for 07:00, failed.")
  }
  
  func testGetTodayDateString() {
    //given
    let today = Date()
    let format = "yyyy-MM-dd HH:mm"
    let dateTimeFormatter = DateFormatter()
    dateTimeFormatter.dateFormat = format
    let todayString = dateTimeFormatter.string(from: today)

    //when
    let todayStringResult = sut.getTodayDateString(format: format)

    //then
    XCTAssertEqual(todayStringResult, todayString, "Get today date string for now, failed.")
  }
  
  func testGetThisWeekendDateStrings() {
    //given
    let today = Date()
    let format = "yyyy-MM-dd HH:mm"
    let saturdayDate = Calendar.current.nextWeekend(startingAfter: today)?.start ?? today
    let sundayDate = Calendar.current.date(byAdding: .day, value: 1, to: saturdayDate) ?? today
    let saturday = Dates.shared.makeStringFromDate(date: saturdayDate, format: format)
    let sunday = Dates.shared.makeStringFromDate(date: sundayDate, format: format)

    //when
    let weekendStringResult = sut.getThisWeekendDateStrings(format: format)

    //then
    XCTAssertEqual(weekendStringResult, [saturday, sunday])
  }
  
  //  func testPerformance() throws {
  //    // This is an example of a performance test case.
  //    self.measure {
  //      // Put the code you want to measure the time of here.
  //    }
  //  }
}
