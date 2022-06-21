//
//  GlobalViewModel.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/11/22.
//

import Foundation
import Mixpanel

class GlobalViewModel: ObservableObject {
  
  //MARK: Home
  
  @Published public var currentTemp = "--"
  @Published public var currentConditions = "unkown"
  
  func fetchCurrentWeather() {
//    currentTemp = "110°"
//    currentConditions = "Sunny ☀️"
  }

  
  //MARK: EditEventPencil
  
  @Published public var isShowingDailyEvents = false

  func showDailyEvents() {
    Mixpanel.mainInstance().track(event: "Showing DailyEvents")
    isShowingDailyEvents.toggle()
  }
  
}
