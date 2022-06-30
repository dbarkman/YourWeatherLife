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
  
  //MARK: EditEventPencil
  
  @Published var isShowingDailyEvents = false
  
  func showDailyEvents() {
    Mixpanel.mainInstance().track(event: "Showing DailyEvents")
    isShowingDailyEvents.toggle()
  }
}
