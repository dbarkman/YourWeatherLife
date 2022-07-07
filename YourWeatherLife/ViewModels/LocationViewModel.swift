//
//  LocationViewModel.swift
//  YourWeatherLife
//
//  Created by David Barkman on 7/7/22.
//

import Foundation
import CoreLocation

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
  @Published var authorizationStatus: CLAuthorizationStatus
  @Published var lastSeenLocation: CLLocation?
  @Published var currentPlacemark: CLPlacemark?
  
  private let locationManager: CLLocationManager
  
  override init() {
    locationManager = CLLocationManager()
    authorizationStatus = locationManager.authorizationStatus
    
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    locationManager.startUpdatingLocation()
  }
  
  func requestPermission() {
    locationManager.requestWhenInUseAuthorization()
  }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    NotificationCenter.default.post(name: .locationUpdatedEvent, object: nil)
    authorizationStatus = manager.authorizationStatus
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    lastSeenLocation = locations.first
    //    fetchCountryAndCity(for: locations.first)
  }
  
  func fetchCountryAndCity(for location: CLLocation?) {
    guard let location = location else { return }
    let geocoder = CLGeocoder()
    geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
      self.currentPlacemark = placemarks?.first
    }
  }
}
