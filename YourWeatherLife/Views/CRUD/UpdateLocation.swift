//
//  EditLocation.swift
//  YourWeatherLife
//
//  Created by David Barkman on 7/20/22.
//

import SwiftUI
import Mixpanel
import OSLog

struct UpdateLocation: View {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "UpdateLocation")
  
  @Environment(\.presentationMode) var presentationMode
  @Environment(\.colorScheme) var colorScheme
  
  @StateObject private var locationViewModel = LocationViewModel.shared
  
  @State private var location = 0
  @State private var manualLocation = 0
  @State private var zipcode = ""
  @State private var latitude = ""
  @State private var longitude = ""
  @State private var updateLocationResult = ""
  
  @Binding var refreshLocation: Bool
  
  var body: some View {
    NavigationView {
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
              Text("Will you provide zip/postal code or latitude and longitude coordinates?")
              Picker("", selection: $manualLocation) {
                Text("Zip/Postal Code").tag(0)
                Text("Lat/Long").tag(1)
              }
              .pickerStyle(.segmented)
              if manualLocation == 0 {
                HStack {
                  Text("Zip/Postal Code:")
                  TextField("zip/postal code", text: $zipcode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .environment(\.colorScheme, .light)
                    .keyboardType(.numberPad)
                }
              }
              if manualLocation == 1 {
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
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(Color("NavigationBackground"))//.opacity(0.9))
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(Color("AccentColor"))
        Mixpanel.mainInstance().track(event: "UpdateLocation view")
        
        let automaticLocation = UserDefaults.standard.bool(forKey: "automaticLocation")
        location = automaticLocation ? 0 : 1
        guard let manualLocationData = UserDefaults.standard.string(forKey: "manualLocationData") else { return }
        if manualLocationData.contains(",") {
          manualLocation = 1
          if let latitude = manualLocationData.components(separatedBy: ",").first, let longitude = manualLocationData.components(separatedBy: ",").last {
            self.latitude = latitude
            self.longitude = longitude
          }
        } else {
          manualLocation = 0
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
      UserDefaults.standard.set(true, forKey: "automaticLocation")
    } else {
      UserDefaults.standard.set(false, forKey: "automaticLocation")
      if manualLocation == 0 {
        if zipcode.isEmpty {
          updateLocationResult = "Zip/Postal Code cannot be empty."
          return
        } else if zipcode.count < 3 {
          updateLocationResult = "Zip/Postal Code is too short."
          return
        }
        UserDefaults.standard.set(zipcode, forKey: "manualLocationData")
      } else {
        if latitude.isEmpty || longitude.isEmpty {
          updateLocationResult = "Both latitude and longitude must be entered."
          return
        }
        UserDefaults.standard.set("\(latitude),\(longitude)", forKey: "manualLocationData")
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
