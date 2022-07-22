//
//  LocationViewModel.swift
//  YourWeatherLife
//
//  Created by David Barkman on 7/7/22.
//

import Foundation
import CoreLocation
import OSLog

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "LocationViewModel")

  @Published var lastSeenLocation: CLLocation?
  @Published var currentPlacemark: CLPlacemark?
  @Published var authorizationStatus: CLAuthorizationStatus {
    didSet {
      guard oldValue != authorizationStatus else { return }
      NotificationCenter.default.post(name: .locationUpdatedEvent, object: nil)
      logger.debug("LocationManager DidChangeAuthorization")
    }
  }

  private let locationManager: CLLocationManager
  
  override init() {
    locationManager = CLLocationManager()
    authorizationStatus = locationManager.authorizationStatus
    
    super.init()
    locationManager.delegate = self
//    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
//    locationManager.startUpdatingLocation()
    locationManager.startMonitoringSignificantLocationChanges()
    locationManager.pausesLocationUpdatesAutomatically = true
  }
  
  func requestPermission() {
    locationManager.requestWhenInUseAuthorization()
  }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    authorizationStatus = manager.authorizationStatus
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//    logger.debug("LocationManager DidUpdateLocations")
  }
}
