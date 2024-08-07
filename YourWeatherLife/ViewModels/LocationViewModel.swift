//
//  LocationViewModel.swift
//  YourWeatherLife
//
//  Created by David Barkman on 7/7/22.
//

import Foundation
import CoreLocation
import Mixpanel
import OSLog

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "LocationViewModel")
  
  static let shared = LocationViewModel()
  
  @Published var lastSeenLocation: CLLocation? {
    didSet {
      guard oldValue != lastSeenLocation else { return }
      logger.debug("LocationManager lastSeenLocation updated")
    }
  }
  @Published var currentPlacemark: CLPlacemark? {
    didSet {
      guard oldValue != currentPlacemark else { return }
      logger.debug("LocationManager currentPlacemark updated")
    }
  }
  @Published var authorizationStatus: CLAuthorizationStatus {
    didSet {
      guard oldValue != authorizationStatus else { return }
      logger.debug("LocationManager authorizationStatus updated")
      NotificationCenter.default.post(name: .locationUpdatedEvent, object: nil)
      if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
        UserDefaults.standard.set(true, forKey: "automaticLocation")
      } else {
        Mixpanel.mainInstance().track(event: "Location Not Authorized")
        UserDefaults.standard.set(false, forKey: "automaticLocation")
        if UserDefaults.standard.string(forKey: "manualLocationData") == nil {
          UserDefaults.standard.set("98034", forKey: "manualLocationData")
        } else {
          logger.debug("manual location: \(UserDefaults.standard.string(forKey: "manualLocationData") ?? "")")
        }
      }
      Task {
        await AsyncAPI.shared.getZoneId()
        let token = UserDefaults.standard.string(forKey: "apnsToken") ?? ""
        let debug = UserDefaults.standard.integer(forKey: "apnsDebug")
        await AsyncAPI.shared.saveToken(token: token, debug: debug)
      }
    }
  }

  let locationManager: CLLocationManager
  
  override private init() {
    locationManager = CLLocationManager()
    authorizationStatus = locationManager.authorizationStatus
    
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
//    locationManager.startUpdatingLocation()
    locationManager.pausesLocationUpdatesAutomatically = true
    locationManager.startMonitoringSignificantLocationChanges()
  }
  
  func requestPermission() {
    locationManager.requestWhenInUseAuthorization()
  }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    authorizationStatus = manager.authorizationStatus
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    lastSeenLocation = locations.first
  }
}
