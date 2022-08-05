//
//  GetAllDataTests.swift
//  YourWeatherLifeTests
//
//  Created by David Barkman on 7/31/22.
//

import XCTest
@testable import YourWeatherLife

class GetAllDataTests: XCTestCase {
  
  var sut: GetAllData!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    sut = GetAllData.shared
  }
  
  override func tearDownWithError() throws {
    sut = nil
    try super.tearDownWithError()
  }
  
  func testFetchCurrentConditions() {
    //given
    let nextUpdate = Date(timeIntervalSince1970: 0)
    UserDefaults.standard.set(nextUpdate, forKey: "currentConditionsNextUpdate")

    //when
    let fetchCurrentConditionsResult1 = sut.fetchCurrentConditions()
    let fetchCurrentConditionsResult2 = sut.fetchCurrentConditions()
    
    //then
    XCTAssertTrue(fetchCurrentConditionsResult1, "Fetch current conditions with date reset to 1970, faled.")
    XCTAssertFalse(fetchCurrentConditionsResult2, "Fetch current conditions again, faled.")
  }
  
  func testUpdateForecastsDateReset() async {
    //given
    let nextUpdate = Date(timeIntervalSince1970: 0)
    UserDefaults.standard.set(nextUpdate, forKey: "forecastsNextUpdate")
    expectation(forNotification: .forecastInsertedEvent, object: nil, handler: nil)
    
    //when
    await sut.updateForecasts()
    
    //then
    await waitForExpectations(timeout: 5, handler: nil)
  }
  
  func testUpdateForecasts() async {
    //given
    let forecastsNextUpdate = UserDefaults.standard.object(forKey: "forecastsNextUpdate") as? Date
    
    //when
    await sut.updateForecasts()
    let result = UserDefaults.standard.object(forKey: "forecastsNextUpdate") as? Date

    //then
    XCTAssertEqual(result, forecastsNextUpdate, "Update forecasts again, failed.")
  }
  
  func testTemplate() throws {
    //given
    //when
    //then
  }
  
//  func testPerformanceExample() throws {
//    // This is an example of a performance test case.
//    self.measure {
//      // Put the code you want to measure the time of here.
//    }
//  }
}
