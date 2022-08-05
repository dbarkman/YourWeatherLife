//
//  HomeViewModelTests.swift
//  YourWeatherLifeTests
//
//  Created by David Barkman on 8/1/22.
//

import XCTest
@testable import YourWeatherLife

class HomeViewModelTests: XCTestCase {
  var sut: HomeViewModel!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    sut = HomeViewModel.shared
  }
  
  override func tearDownWithError() throws {
    sut = nil
    try super.tearDownWithError()
  }

  func testNotificationObservers() {
    //given
    let locationUpdatedExpectation = expectation(forNotification: .locationUpdatedEvent, object: nil)
    let forcastInsertedExpectation = expectation(forNotification: .forecastInsertedEvent, object: nil)
    let nextStartDateUpdatedExpectation = expectation(forNotification: .nextStartDateUpdated, object: nil)

    //when
    NotificationCenter.default.post(name: .locationUpdatedEvent, object: nil)

    //then
    wait(for: [locationUpdatedExpectation], timeout: 5)
    wait(for: [forcastInsertedExpectation], timeout: 5)
    wait(for: [nextStartDateUpdatedExpectation], timeout: 5)
  }
}
