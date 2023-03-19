//
//  Review.swift
//  YourWeatherLife
//
//  Created by David Barkman on 3/19/23.
//

import StoreKit
import Mixpanel

class Review {
  
  private let ud = UserDefaults.standard
  private let minLaunches = 3 //set to 1 to test, default: 3
  private let minDays = 2 //set to 0 to test, default: 2
  private let daysBetweenReviews = 90
  
  private var version = Bundle.main.object(
    forInfoDictionaryKey: "CFBundleShortVersionString"
  ) as! String
  
  private var eventDetailViewed: Bool {
    get { ud.bool(forKey: "eventDetailViewed") }
    set(value) { ud.set(value, forKey: "eventDetailViewed") }
  }
  
  private var calendarEventsViewed: Bool {
    get { ud.bool(forKey: "calendarEventsViewed") }
    set(value) { ud.set(value, forKey: "calendarEventsViewed") }
  }
  
  private var dayForecastViewed: Bool {
    get { ud.bool(forKey: "dayForecastViewed") }
    set(value) { ud.set(value, forKey: "dayForecastViewed") }
  }
  
  private var hourForecastViewed: Bool {
    get { ud.bool(forKey: "hourForecastViewed") }
    set(value) { ud.set(value, forKey: "hourForecastViewed") }
  }
  
  private var launches: Int {
    get { ud.integer(forKey: "launches") }
    set(value) { ud.set(value, forKey: "launches") }
  }
  
  private var firstLaunchDate: Date? {
    get { ud.object(forKey: "firstLaunchDate") as? Date }
    set(value) { ud.set(value, forKey: "firstLaunchDate") }
  }
  
  private var lastReviewDate: Date? {
    get { ud.object(forKey: "lastReviewDate") as? Date }
    set(value) { ud.set(value, forKey: "lastReviewDate") }
  }
  
  private var daysInstalled: Int {
    if let date = firstLaunchDate {
      return daysBetween(date, Date())
    }
    return 0
  }
  
  private var daysSinceLastReview: Int {
    if let date = lastReviewDate {
      return daysBetween(date, Date())
    }
    return 0
  }
  
  private var lastRequestVersion: String? {
    get { ud.string(forKey: "lastRequestVersion") }
    set(value) { ud.set(value, forKey: "lastRequestVersion") }
  }
  
  private func daysBetween(_ start: Date, _ end: Date) -> Int {
    Calendar.current.dateComponents([.day], from: start, to: end).day!
  }

  private func requestReviewIfReady() {
    if firstLaunchDate == nil { firstLaunchDate = Date() }
    launches += 1
    if eventDetailViewed && calendarEventsViewed && dayForecastViewed && hourForecastViewed && launches >= minLaunches && daysInstalled >= minDays {
      if lastReviewDate == nil || daysSinceLastReview >= daysBetweenReviews {
        Mixpanel.mainInstance().track(event: "Review Requested for \(version)")
        lastReviewDate = Date()
        lastRequestVersion = version
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
          }
        }
      }
    }
  }
  
  //these get called throughout the app
  static func eventDetailViewed() {
    Review().eventDetailViewed = true
  }
  
  static func calendarEventsViewed() {
    Review().calendarEventsViewed = true
  }
  
  static func dayForecastViewed() {
    Review().dayForecastViewed = true
  }
  
  static func hourForecastViewed() {
    Review().hourForecastViewed = true
  }
  
  static func requestReview() {
    Review().requestReviewIfReady()
  }
  
}
