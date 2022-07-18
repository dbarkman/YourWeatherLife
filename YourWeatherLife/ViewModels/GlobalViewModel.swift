//
//  GlobalViewModel.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/11/22.
//

import Foundation
import CoreData
import Network
import Mixpanel
import OSLog

class GlobalViewModel: ObservableObject {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "GlobalViewModel")
  
  let monitor = NWPathMonitor()
  
  var viewContext: NSManagedObjectContext
  var viewCloudContext: NSManagedObjectContext
  
  private var locationViewModel = LocationViewModel()
  
  @Published var isShowingDailyEvents = false
  @Published var returningFromChildView = false
  @Published var today = Dates.getTodayDateString(format: "yyyy-MM-dd")
  @Published var weekend = Dates.getThisWeekendDateStrings(format: "yyyy-MM-dd")
  @Published var networkOnline = true {
    didSet {
      guard oldValue != networkOnline else { return }
      if networkOnline {
        self.locationViewModel.requestPermission()
      }
    }
  }
  
  init(viewContext: NSManagedObjectContext, viewCloudContext: NSManagedObjectContext) {
    self.viewContext = viewContext
    self.viewCloudContext = viewCloudContext
    
    monitor.pathUpdateHandler = { path in
      if path.status == .satisfied {
        self.checkInternetConnection(closure: { connected in
          if connected {
            self.logger.debug("dbark - Network connected!")
            DispatchQueue.main.async {
              self.networkOnline = true
            }
          } else {
            DispatchQueue.main.async {
              self.networkOnline = false
            }
            self.logger.debug("dbark - Connected to a network, but the Internet is not available.")
          }
        })
      } else {
        self.logger.debug("dbark - No network connection.")
        DispatchQueue.main.async {
          self.networkOnline = false
        }
      }
    }
    let queue = DispatchQueue(label: "Monitor")
    monitor.start(queue: queue)
  }
  
  func countEverything() {
    let fetchRequest1: NSFetchRequest<DailyEvent>
    fetchRequest1 = DailyEvent.fetchRequest()
    fetchRequest1.predicate = NSPredicate(value: true)
    do {
      let events = try viewCloudContext.fetch(fetchRequest1)
      logger.debug("Event count: \(events.count)")
    } catch {
      logger.debug("Couldn't get event count.")
    }

    let fetchRequest2: NSFetchRequest<TGWForecastDay>
    fetchRequest2 = TGWForecastDay.fetchRequest()
    fetchRequest2.predicate = NSPredicate(value: true)
    do {
      let days = try viewContext.fetch(fetchRequest2)
      logger.debug("Forecast Day count: \(days.count)")
    } catch {
      logger.debug("Couldn't get days count.")
    }

    let fetchRequest3: NSFetchRequest<TGWForecastHour>
    fetchRequest3 = TGWForecastHour.fetchRequest()
    fetchRequest3.predicate = NSPredicate(value: true)
    do {
      let hours = try viewContext.fetch(fetchRequest3)
      logger.debug("Forecast Hour count: \(hours.count)")
    } catch {
      logger.debug("Couldn't get hours count.")
    }
  }
  
  func checkInternetConnection(closure: @escaping (Bool) -> Void) {
    if let url = URL(string: "https://weather.solutions/test.html") {
      var request = URLRequest(url: url)
      request.httpMethod = "HEAD"
      request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
      request.timeoutInterval = 5
      let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
        closure(error == nil)
      })
      task.resume()
    } else {
      closure(false)
    }
  }
  
  //MARK: EditEventPencil
  
  func showDailyEvents() {
    Mixpanel.mainInstance().track(event: "Showing DailyEvents")
    isShowingDailyEvents.toggle()
  }
}
