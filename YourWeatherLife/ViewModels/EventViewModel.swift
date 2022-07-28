//
//  EventViewModel.swift
//  YourWeatherLife
//
//  Created by David Barkman on 7/17/22.
//

import Foundation
import Mixpanel
import OSLog

class EventViewModel: ObservableObject {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "EventViewModel")
  
  static let shared = EventViewModel()
  
  @Published var eventSaveResult = ""
  @Published var daysSelected = ""
  @Published var selectedSet: Set<String> = [""]
  @Published var returningFromDays = false

  private var days = ""

  var selectedDays = [Int]()
  
  private init() { }
  
  func saveEvent(eventName: String, startTimeDate: Date, endTimeDate: Date, oldEventName: String = "", addEvent: Bool = false, closure: @escaping (Bool) -> Void) {
    guard !eventName.isEmpty else {
      Mixpanel.mainInstance().track(event: "Event Name Blank")
      DispatchQueue.main.async {
        self.eventSaveResult = "Event name cannot be blank"
      }
      return
    }
    
    if startTimeDate == endTimeDate {
      Mixpanel.mainInstance().track(event: "Event Times Equal")
      eventSaveResult = "Times must be 1 hour apart or more"
      return
    }

    var days = ""
    for selected in selectedDays {
      days.append("\(selected)")
    }

    let event = Event(event: eventName, startTime: Dates.shared.makeStringFromDate(date: startTimeDate, format: "HH:mm"), endTime: Dates.shared.makeStringFromDate(date: endTimeDate, format: "HH:mm"), summary: "", nextStartDate: "", when: "", days: days)
    var result = EventResult.noResult
    if addEvent {
      Mixpanel.mainInstance().track(event: "Event Added")
      result = EventProvider.shared.insertEvents(eventList: [event])
    } else {
      Mixpanel.mainInstance().track(event: "Event Updated")
      result = EventProvider.shared.updateEvents(event: event, oldEventName: oldEventName)
    }
    DispatchQueue.main.async {
      switch result {
        case .eventSaved:
          closure(true)
        case .eventNotSaved:
          Mixpanel.mainInstance().track(event: "Event could not be saved")
          self.eventSaveResult = "Event could not be saved"
        case .eventExists:
          Mixpanel.mainInstance().track(event: "Event already exists")
          self.eventSaveResult = "Event already exists"
        default:
          Mixpanel.mainInstance().track(event: "Error saving event")
          self.eventSaveResult = "Error saving event"
      }
    }
  }
  
  func convertDaysSelected(selection: Set<String>) {
    var selectedInts: [Int] = []

    for select in selection {
      switch select {
        case "Sunday":
          selectedInts.append(1)
          days.append("1,")
        case "Monday":
          selectedInts.append(2)
          days.append("2,")
        case "Tuesday":
          selectedInts.append(3)
          days.append("3,")
        case "Wednesday":
          selectedInts.append(4)
          days.append("4,")
        case "Thursday":
          selectedInts.append(5)
          days.append("5,")
        case "Friday":
          selectedInts.append(6)
          days.append("6,")
        case "Saturday":
          selectedInts.append(7)
          days.append("7,")
        default:
          logger.error("Could not determine a selection. 😭")
      }
    }
    convertSelectedInts(selectedInts: &selectedInts)
    self.selectedDays = selectedInts
  }
  
  func convertSelectedInts(selectedInts: inout [Int]) {
    var selected = ""
    var selectedSet: Set<String> = []
    
    selectedInts.sort()
    for select in selectedInts {
      switch select {
        case 1:
          selected.append("Sun ")
          selectedSet.insert("Sunday")
        case 2:
          selected.append("Mon ")
          selectedSet.insert("Monday")
        case 3:
          selected.append("Tue ")
          selectedSet.insert("Tuesday")
        case 4:
          selected.append("Wed ")
          selectedSet.insert("Wednesday")
        case 5:
          selected.append("Thu ")
          selectedSet.insert("Thursday")
        case 6:
          selected.append("Fri ")
          selectedSet.insert("Friday")
        case 7:
          selected.append("Sat ")
          selectedSet.insert("Saturday")
        default:
          logger.error("Could not determine a selected int. 😭")
      }
    }
    DispatchQueue.main.async {
      self.daysSelected = ""
      self.daysSelected = selected
      self.selectedSet.removeAll()
      self.selectedSet = selectedSet
    }
  }
  
  func convertAndReturnDays(days: [Int]) -> String {
    var selectedInts = days
    selectedInts.sort()
    var selected = ""
    for select in selectedInts {
      switch select {
        case 1:
          selected.append("Sun, ")
        case 2:
          selected.append("Mon, ")
        case 3:
          selected.append("Tue, ")
        case 4:
          selected.append("Wed, ")
        case 5:
          selected.append("Thu, ")
        case 6:
          selected.append("Fri, ")
        case 7:
          selected.append("Sat, ")
        default:
          logger.error("Could not determine a selected int. 😭")
      }
    }
    return String(selected.dropLast(2))
  }
}
