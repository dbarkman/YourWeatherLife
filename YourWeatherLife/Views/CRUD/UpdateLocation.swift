//
//  EditLocation.swift
//  YourWeatherLife
//
//  Created by David Barkman on 7/20/22.
//

import SwiftUI
import Mixpanel
import OSLog
import FirebaseAnalytics

struct UpdateLocation: View {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "UpdateLocation")
  
  @Environment(\.presentationMode) var presentationMode
  @Environment(\.colorScheme) var colorScheme
  
  @StateObject private var locationViewModel = LocationViewModel.shared
  
  @State private var location = 0
  @State private var manualLocation = 0
  @State private var city = ""
  @State private var state = ""
  @State private var zipcode = ""
  @State private var latitude = ""
  @State private var longitude = ""
  @State private var updateLocationResult = ""
  
  @Binding var refreshLocation: Bool
  
  var body: some View {
    NavigationStack {
      ZStack {
        BackgroundColor()
        List {
          Section() {
            Text("How should location be determined?")
            Picker("", selection: $location) {
              Text("Automatically").tag(0)
              Text("Manually").tag(1)
            }
            .pickerStyle(.segmented)
            if location == 0 {
              if locationViewModel.authorizationStatus == .authorizedAlways || locationViewModel.authorizationStatus == .authorizedWhenInUse {
                Text("Location will be determined using your device's GPS.")
              } else {
                Text("\"Your Weather\" is not currently allowed to access your location. To enable automatic location, tap Open Settings below and grant location access to this app.")
                Button(action: {
                  withAnimation() {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                      UIApplication.shared.open(settingsUrl)
                    }
                  }
                }, label: {
                  Text("Open Settings")
                    .foregroundColor(Color("AccentColor"))
                })
              }
            } else if location == 1 {
              Text("Will you provide city, state/region, zip/postal code or latitude and longitude coordinates?")
              Picker("", selection: $manualLocation) {
                Text("City, State").tag(0)
                Text("Zip/Postal Code").tag(1)
                Text("Lat/Long").tag(2)
              }
              .pickerStyle(.segmented)
              if manualLocation == 0 {
                HStack {
                  Text("City:")
                  TextField("city", text: $city)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .environment(\.colorScheme, .light)
                    .keyboardType(.numbersAndPunctuation)
                }
                HStack {
                  Text("State/Region:")
                  TextField("state/region", text: $state)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .environment(\.colorScheme, .light)
                    .keyboardType(.numbersAndPunctuation)
                }
              }
              if manualLocation == 1 {
                HStack {
                  Text("Zip/Postal Code:")
                  TextField("zip/postal code", text: $zipcode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .environment(\.colorScheme, .light)
                    .keyboardType(.numbersAndPunctuation)
                }
              }
              if manualLocation == 2 {
                HStack {
                  Text("Latitude:")
                  TextField("latitude", text: $latitude)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .environment(\.colorScheme, .light)
                    .keyboardType(.numbersAndPunctuation)
                }
                HStack {
                  Text("Longitude:")
                  TextField("longitude", text: $longitude)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .environment(\.colorScheme, .light)
                    .keyboardType(.numbersAndPunctuation)
                }
              }
            }
            if !updateLocationResult.isEmpty {
              HStack {
                Text(updateLocationResult)
                Spacer()
                Text("OK")
                  .onTapGesture(perform: {
                    withAnimation() {
                      updateLocationResult = ""
                    }
                  })
              }
              .listRowBackground(Color.red.opacity(0.75))
            }
            HStack {
              Text("Update")
                .font(.title2)
                .foregroundColor(Color("AccentColor"))
                .onTapGesture {
                  withAnimation() {
                    updateLocation()
                  }
                }
              if location == 0 && refreshLocation {
                Spacer()
                Text("Refresh Location")
                  .font(.title2)
                  .foregroundColor(Color("AccentColor"))
                  .onTapGesture {
                    withAnimation() {
                      refreshLocation = false
                      updateLocation()
                    }
                  }
              }
            }
          }
          .listRowBackground(Color("ListBackground"))
        } //end of List
        .listStyle(.plain)
        .navigationBarTitle("Update Location")
      } //end of ZStack
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: {
            presentationMode.wrappedValue.dismiss()
          }) {
            Text("Cancel")
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            updateLocation()
          }) {
            Text("Update")
          }
        }
      }
      .onAppear() {
        UINavigationBar.appearance().tintColor = UIColor(Color("AccentColor"))
        Mixpanel.mainInstance().track(event: "UpdateLocation View")
        Analytics.logEvent("View", parameters: ["view_name": "UpdateLocation"])

        let automaticLocation = UserDefaults.standard.bool(forKey: "automaticLocation")
        location = automaticLocation ? 0 : 1
        guard let manualLocationData = UserDefaults.standard.string(forKey: "manualLocationData") else { return }
        let manualLocation = UserDefaults.standard.integer(forKey: "manualLocation")
        self.manualLocation = manualLocation
        if manualLocation == 0 {
          if !manualLocationData.contains(",") {
            city = "Kirkland"
            state = "WA"
          } else {
            city = manualLocationData.components(separatedBy: ",").first ?? "Kirkland"
            state = manualLocationData.components(separatedBy: ",").last ?? "WA"
          }
        } else if manualLocation == 2 {
          if let latitude = manualLocationData.components(separatedBy: ",").first, let longitude = manualLocationData.components(separatedBy: ",").last {
            self.latitude = latitude
            self.longitude = longitude
          }
        } else {
          zipcode = manualLocationData
        }
      }
    }
    .accentColor(Color("AccentColor"))
  }
  
  private func updateLocation() {
    if location == 0 {
      if locationViewModel.authorizationStatus != .authorizedWhenInUse && locationViewModel.authorizationStatus != .authorizedAlways {
        updateLocationResult = "Location permission must be granted in order to use automatic location."
        return
      }
      Mixpanel.mainInstance().track(event: "Location by GPS")
      UserDefaults.standard.set(true, forKey: "automaticLocation")
      Task {
        await AsyncAPI.shared.getZoneId()
        let token = UserDefaults.standard.string(forKey: "apnsToken") ?? ""
        let debug = UserDefaults.standard.integer(forKey: "apnsDebug")
        await AsyncAPI.shared.saveToken(token: token, debug: debug)
      }
    } else {
      UserDefaults.standard.set(false, forKey: "automaticLocation")
      if manualLocation == 0 {
        if city.isEmpty || state.isEmpty {
          updateLocationResult = "Both city and state/region must be entered."
          return
        }
        Mixpanel.mainInstance().track(event: "Location by City, State")
        UserDefaults.standard.set("\(city),\(state)", forKey: "manualLocationData")
      } else if manualLocation == 1 {
        if zipcode.isEmpty {
          updateLocationResult = "Zip/Postal Code cannot be empty."
          return
        } else if zipcode.count < 3 {
          updateLocationResult = "Zip/Postal Code is too short."
          return
        }
        Mixpanel.mainInstance().track(event: "Location by Zip/Postal Code")
        UserDefaults.standard.set(zipcode, forKey: "manualLocationData")
      } else if manualLocation == 2 {
        if latitude.isEmpty || longitude.isEmpty {
          updateLocationResult = "Both latitude and longitude must be entered."
          return
        }
        Mixpanel.mainInstance().track(event: "Location by Lat/Long")
        UserDefaults.standard.set("\(latitude),\(longitude)", forKey: "manualLocationData")
      }
      UserDefaults.standard.set(manualLocation, forKey: "manualLocation")
      Task {
        await AsyncAPI.shared.getZoneId()
        let token = UserDefaults.standard.string(forKey: "apnsToken") ?? ""
        let debug = UserDefaults.standard.integer(forKey: "apnsDebug")
        await AsyncAPI.shared.saveToken(token: token, debug: debug)
      }
    }
    NotificationCenter.default.post(name: .locationUpdatedEvent, object: nil)
    presentationMode.wrappedValue.dismiss()
  }
}

//struct EditLocation_Previews: PreviewProvider {
//  static var previews: some View {
//    UpdateLocation()
//  }
//}
