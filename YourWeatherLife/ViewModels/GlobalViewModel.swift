//
//  GlobalViewModel.swift
//  YourDay
//
//  Created by David Barkman on 6/11/22.
//

import Foundation
import Mixpanel

class GlobalViewModel: ObservableObject {
  
  @Published public var isShowingDailyEvents = false
  
  func showDailyEvents() {
    Mixpanel.mainInstance().track(event: "Showing DailyEvents")
    isShowingDailyEvents.toggle()
  }
  
}
