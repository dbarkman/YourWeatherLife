//
//  YourWeatherLifeUITestsLaunchTests.swift
//  YourWeatherLifeUITests
//
//  Created by David Barkman on 6/19/22.
//

import XCTest

class YourWeatherLifeUITestsLaunchTests: XCTestCase {
  
  let app = XCUIApplication()
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    continueAfterFailure = false
    app.launch()
  }
  
  override func tearDownWithError() throws {
    app.terminate()
    try super.tearDownWithError()
  }
  
  func testNavigation() {
    let weekendPredicate = NSPredicate(format: "label beginswith 'Weekend'")
    app.tabBars.buttons.element(matching: weekendPredicate).tap()
    XCTAssert(app.staticTexts["This Weekend"].exists)
  }
  
//  func testLaunchPerformance() throws {
//    if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
//      // This measures how long it takes to launch your application.
//      measure(metrics: [XCTApplicationLaunchMetric()]) {
//        XCUIApplication().launch()
//      }
//    }
//  }
}
