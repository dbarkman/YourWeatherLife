//
//  GlobalViewModel.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/11/22.
//

import Foundation
import Mixpanel
import OSLog
import CoreData

class GlobalViewModel: ObservableObject {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "GlobalViewModel")
  
  var viewContext: NSManagedObjectContext
  var viewCloudContext: NSManagedObjectContext
  
  @Published var isShowingDailyEvents = false
  @Published var today = Dates.getTodayDateString(format: "yyyy-MM-dd")
  @Published var weekend = Dates.getThisWeekendDateStrings(format: "yyyy-MM-dd")
  
  
  init(viewContext: NSManagedObjectContext, viewCloudContext: NSManagedObjectContext) {
    self.viewContext = viewContext
    self.viewCloudContext = viewCloudContext
  }
  
  //MARK: EditEventPencil
  
  func showDailyEvents() {
    Mixpanel.mainInstance().track(event: "Showing DailyEvents")
    isShowingDailyEvents.toggle()
  }
}
