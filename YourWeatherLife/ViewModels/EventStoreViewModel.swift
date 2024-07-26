//
//  EventStoreViewModel.swift
//  YourWeatherLife
//
//  Created by David Barkman on 1/18/23.
//

import Foundation
import EventKit
import OSLog

class EventStoreViewModel: ObservableObject {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "EventStoreViewModel")
  
  static let shared = EventStoreViewModel()
  
  @Published var calendarSets: [CalendarSet] = []
  @Published var eventSets: [EventSet] = []
  @Published var eventIdsByName: [String:String] = [:]
  @Published var eventsById: [String:EKEvent] = [:]
  @Published var allCalendarsSelected = false
  
  private var selectedCalendarIds: [String] = []
  
  let store: EKEventStore
  
  private init() {
    store = EKEventStore()

    fetchCalendars()
  }

  func fetchCalendars() {
    DispatchQueue.main.async {
      self.calendarSets.removeAll()
      let calendars = self.store.calendars(for: .event)
      for calendar in calendars {
        self.logger.debug("Calendar: \(calendar.title)")
        let sectionHeader = calendar.source.title
        if let sectionIndex = self.calendarSets.firstIndex(where: { $0.title == sectionHeader }) {
          self.calendarSets[sectionIndex].calendars.append(calendar)
        } else {
          self.calendarSets.append(CalendarSet(title: sectionHeader, calendars: [calendar]))
        }
      }
    }
  }

  func fetchEvents() {
    DispatchQueue.main.async {
      self.eventSets.removeAll()
      self.eventIdsByName.removeAll()
      self.eventsById.removeAll()
    }
    let today = Date()
    let calendar = Calendar.current
    var twoWeeksFromNowComponents = DateComponents()
    twoWeeksFromNowComponents.day = 14
    let twoWeeksFromNow = calendar.date(byAdding: twoWeeksFromNowComponents, to: today, wrappingComponents: false)
    
    //get selected calendars
    var selectedCalendars: [EKCalendar] = []
    if let selection = UserDefaults.standard.object(forKey: "selectedCalendars") as? [String] {
      for id in selection {
        if let calendar = store.calendar(withIdentifier: id) {
          selectedCalendars.append(calendar)
        }
      }
    } else {
      DispatchQueue.main.async {
        self.allCalendarsSelected = true
      }
      selectedCalendars = self.store.calendars(for: .event)
      for calendar in selectedCalendars {
        selectedCalendarIds.append(calendar.calendarIdentifier)
      }
      UserDefaults.standard.set(Array(selectedCalendarIds), forKey: "selectedCalendars")
    }
    
    var predicate: NSPredicate? = nil
    if let twoWeeks = twoWeeksFromNow {
      predicate = store.predicateForEvents(withStart: today, end: twoWeeks, calendars: selectedCalendars)
    }
    
    var events: [EKEvent] = []
    if let predicate = predicate, selectedCalendars.count > 0 {
      events = store.events(matching: predicate)
    }
    DispatchQueue.main.async {
      events.sort { $0.startDate < $1.startDate }
      for event in events {
        let title = event.title ?? ""
        var date = Dates.shared.makeStringFromDate(date: event.startDate, format: "EEEE, MMMM d' at 'h:mm a")
        if event.isAllDay {
          date = Dates.shared.makeStringFromDate(date: event.startDate, format: "EEEE, MMMM d")
        }
        let eventTitle = "\(title) on \(date)"
        self.eventIdsByName["\(title) on \(date)"] = event.eventIdentifier
        self.eventsById[event.eventIdentifier] = event
        let sectionHeader = event.calendar.title
        if let sectionIndex = self.eventSets.firstIndex(where: { $0.calendar == sectionHeader }) {
          self.eventSets[sectionIndex].events.append(eventTitle)
        } else {
          self.eventSets.append(EventSet(calendar: event.calendar.title, color: event.calendar.cgColor, events: [eventTitle]))
        }
      }
    }
  }
  
  func requestAccess() {
    store.requestAccess(to: .event) { granted, error in
      if let error = error {
        self.logger.error("Problem granting access: \(error.localizedDescription)")
      } else if granted {
        self.logger.debug("Event access granted! 🎉")
        self.fetchEvents()
      } else {
        self.logger.debug("Event access not granted! 😭")
      }
    }
  }
}
