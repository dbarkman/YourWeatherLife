//
//  EventViewModel.swift
//  YourWeatherLife
//
//  Created by David Barkman on 7/17/22.
//

import Foundation

class EventViewModel: ObservableObject {
  
  @Published var eventSaveResult = ""
  
  func saveEvent(eventName: String, startTimeDate: Date, endTimeDate: Date, oldEventName: String = "", addEvent: Bool = false, closure: @escaping (Bool) -> Void) {
    guard !eventName.isEmpty else {
      eventSaveResult = "Event name cannot be blank"
      return
    }
    let timeDifference = Calendar.current.dateComponents([.hour], from: startTimeDate, to: endTimeDate)
    if let hourDiff = timeDifference.hour, hourDiff < 1 {
      eventSaveResult = "Times must be 1 hour apart or more"
      return
    }
    let event = Event(event: eventName, startTime: Dates.makeStringFromDate(date: startTimeDate, format: "HH:mm"), endTime: Dates.makeStringFromDate(date: endTimeDate, format: "HH:mm"), summary: "", nextStartDate: "", tomorrow: "")
    var result = EventResult.noResult
    if addEvent {
      result = EventProvider.shared.insertEvents(eventList: [event])
    } else {
      result = EventProvider.shared.updateEvents(event: event, oldEventName: oldEventName)
    }
    switch result {
      case .eventSaved:
        closure(true)
      case .eventNotSaved:
        eventSaveResult = "Event could not be saved"
      case .eventExists:
        eventSaveResult = "Event already exists"
      default:
        eventSaveResult = "Error saving event"
    }
  }
}
