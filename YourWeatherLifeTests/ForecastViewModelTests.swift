//
//  ForecastViewModelTests.swift
//  YourWeatherLifeTests
//
//  Created by David Barkman on 8/1/22.
//

import XCTest
@testable import YourWeatherLife

class ForecastViewModelTests: XCTestCase {
  var sut: ForecastViewModel!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    sut = ForecastViewModel.shared
  }
  
  override func tearDownWithError() throws {
    sut = nil
    try super.tearDownWithError()
  }
  
  func testCreate14DayForecast() async {
    //given
    expectation(forNotification: .fourteenDayForecastViewModelPublished, object: nil, handler: nil)
    
    //when
    sut.create14DayForecast()
    
    //then
    await waitForExpectations(timeout: 5, handler: nil)
    let forecastDays = sut.forecastDays
    XCTAssertEqual(forecastDays.count, 14)
    if forecastDays.count > 0 {
      let today = forecastDays[0]
      XCTAssertFalse(today.precipitationTotal.isEmpty)
      XCTAssertFalse(today.coldestTemp.isEmpty)
      XCTAssertFalse(today.coldestTime.isEmpty)
      XCTAssertFalse(today.warmestTemp.isEmpty)
      XCTAssertFalse(today.warmestTime.isEmpty)
      XCTAssertFalse(today.sunriseTemp.isEmpty)
      XCTAssertFalse(today.sunriseTime.isEmpty)
      XCTAssertFalse(today.sunsetTemp.isEmpty)
      XCTAssertFalse(today.sunsetTime.isEmpty)
      XCTAssertFalse(today.dayOfWeek.isEmpty)
      XCTAssertFalse(today.displayDate.isEmpty)
      XCTAssertFalse(today.humidity.isEmpty)
      XCTAssertFalse(today.averageTemp.isEmpty)
      XCTAssertFalse(today.visibility.isEmpty)
      XCTAssertFalse(today.condition.isEmpty)
      XCTAssertFalse(today.conditionIcon.isEmpty)
      XCTAssertFalse(today.wind.isEmpty)
      XCTAssertFalse(today.moonIllumination.isEmpty)
      XCTAssertFalse(today.moonPhase.isEmpty)
      XCTAssertFalse(today.moonRiseTime.isEmpty)
      XCTAssertFalse(today.moonSetTime.isEmpty)
      XCTAssertFalse(today.uv.isEmpty)
      XCTAssertFalse(today.date.isEmpty)
      XCTAssertEqual(today.hours.count, 24)
      if today.precipitation {
        XCTAssertFalse(today.precipitationType.isEmpty)
        XCTAssertFalse(today.precipitationPercent.isEmpty)
      }
      let hours = today.hours
      if hours.count > 0 {
        let hour = hours[0]
        XCTAssertFalse(hour.temperature.isEmpty)
        XCTAssertFalse(hour.feelsLike.isEmpty)
        XCTAssertFalse(hour.heatIndex.isEmpty)
        XCTAssertFalse(hour.windChill.isEmpty)
        XCTAssertFalse(hour.humidity.isEmpty)
        XCTAssertFalse(hour.dewPoint.isEmpty)
        XCTAssertFalse(hour.rainChance.isEmpty)
        XCTAssertFalse(hour.precipAmount.isEmpty)
        XCTAssertFalse(hour.snowChance.isEmpty)
        XCTAssertFalse(hour.wind.isEmpty)
        XCTAssertFalse(hour.windGust.isEmpty)
        XCTAssertFalse(hour.windDirection.isEmpty)
        XCTAssertFalse(hour.pressure.isEmpty)
        XCTAssertFalse(hour.visibility.isEmpty)
        XCTAssertFalse(hour.uv.isEmpty)
        XCTAssertFalse(hour.condition.isEmpty)
        XCTAssertFalse(hour.conditionIcon.isEmpty)
        XCTAssertFalse(hour.time.isEmpty)
        XCTAssertFalse(hour.timeFull.isEmpty)
        XCTAssertFalse(hour.date.isEmpty)
        XCTAssertFalse(hour.displayDate.isEmpty)
        XCTAssertFalse(hour.shortDisplayDate.isEmpty)
        XCTAssertFalse(hour.dayOfWeek.isEmpty)
        if hour.willItRain {
          XCTAssertTrue(hour.willItRain)
        } else {
          XCTAssertFalse(hour.willItRain)
        }
        if hour.willItSnow {
          XCTAssertTrue(hour.willItSnow)
        } else {
          XCTAssertFalse(hour.willItSnow)
        }
      }
    }
  }
  
  func testCreate336HourForecast() async {
    //given
    expectation(forNotification: .threeHundredHourForecastViewModelPublished, object: nil, handler: nil)
    
    //when
    sut.create336HourForecast()
    
    //then
    await waitForExpectations(timeout: 5, handler: nil)
    let forecastHours = sut.forecastHours
    XCTAssertGreaterThanOrEqual(forecastHours.count, 305)
    if forecastHours.count > 0 {
      let hour = forecastHours[0]
      XCTAssertFalse(hour.temperature.isEmpty)
      XCTAssertFalse(hour.feelsLike.isEmpty)
      XCTAssertFalse(hour.heatIndex.isEmpty)
      XCTAssertFalse(hour.windChill.isEmpty)
      XCTAssertFalse(hour.humidity.isEmpty)
      XCTAssertFalse(hour.dewPoint.isEmpty)
      XCTAssertFalse(hour.rainChance.isEmpty)
      XCTAssertFalse(hour.precipAmount.isEmpty)
      XCTAssertFalse(hour.snowChance.isEmpty)
      XCTAssertFalse(hour.wind.isEmpty)
      XCTAssertFalse(hour.windGust.isEmpty)
      XCTAssertFalse(hour.windDirection.isEmpty)
      XCTAssertFalse(hour.pressure.isEmpty)
      XCTAssertFalse(hour.visibility.isEmpty)
      XCTAssertFalse(hour.uv.isEmpty)
      XCTAssertFalse(hour.condition.isEmpty)
      XCTAssertFalse(hour.conditionIcon.isEmpty)
      XCTAssertFalse(hour.time.isEmpty)
      XCTAssertFalse(hour.timeFull.isEmpty)
      XCTAssertFalse(hour.date.isEmpty)
      XCTAssertFalse(hour.displayDate.isEmpty)
      XCTAssertFalse(hour.shortDisplayDate.isEmpty)
      XCTAssertFalse(hour.dayOfWeek.isEmpty)
      if hour.willItRain {
        XCTAssertTrue(hour.willItRain)
      } else {
        XCTAssertFalse(hour.willItRain)
      }
      if hour.willItSnow {
        XCTAssertTrue(hour.willItSnow)
      } else {
        XCTAssertFalse(hour.willItSnow)
      }
    }
  }
}
