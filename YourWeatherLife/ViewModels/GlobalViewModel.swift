//
//  GlobalViewModel.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/11/22.
//

import Foundation
import Mixpanel
import OSLog

class GlobalViewModel: ObservableObject {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "GlobalViewModel")
  
  //MARK: EditEventPencil
  
  @Published public var isShowingDailyEvents = false
  
  func showDailyEvents() {
    Mixpanel.mainInstance().track(event: "Showing DailyEvents")
    isShowingDailyEvents.toggle()
  }
}
