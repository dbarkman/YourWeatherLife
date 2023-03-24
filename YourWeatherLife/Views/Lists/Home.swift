//
//  Home.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/10/22.
//

import SwiftUI
import CoreData
import Mixpanel
import OSLog
import FirebaseAnalytics

struct Home: View {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "Home")
  
  private var viewCloudContext = CloudPersistenceController.shared.container.viewContext

  @Environment(\.scenePhase) var scenePhase

  @ObservedObject private var observer = Observer()
  @StateObject private var globalViewModel = GlobalViewModel.shared
  @StateObject private var homeViewModel = HomeViewModel.shared
  @StateObject private var locationViewModel = LocationViewModel.shared
  @StateObject private var currentConditions = CurrentConditionsViewModel.shared

  @State private var showFeedback = false
  @State private var showUpdateLocation = false
  @State private var refreshLocation = false
  
  var body: some View {
    
    UITableView.appearance().backgroundColor = .clear
    
    return NavigationStack {
      ZStack {
        BackgroundColor()
        VStack {
          List {
            Group {
              if !globalViewModel.networkOnline {
                VStack(alignment: .center) {
                  HStack {
                    Spacer()
                    Text("No Internet Connection")
                      .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "arrow.triangle.2.circlepath")
                      .symbolRenderingMode(.monochrome)
                      .foregroundColor(.white)
                      .onTapGesture(perform: {
                        DispatchQueue.main.async {
                          globalViewModel.networkOnline = true
                        }
                        globalViewModel.checkInternetConnection(closure: { connected in
                          DispatchQueue.main.async {
                            globalViewModel.networkOnline = connected
                          }
                        })
                      })
                    Spacer()
                  }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.red)
              }
              HStack {
                VStack(alignment: .leading) {
                  HStack {
                    Text(currentConditions.current?.temperature ?? "88")
                      .font(.largeTitle)
                      .minimumScaleFactor(0.1)
                      .lineLimit(1)
                    Image(currentConditions.current?.icon ?? "day/113")
                      .padding(.vertical, -32)
                  } //end of HStack
                  Text(currentConditions.current?.condition ?? "Sunny")
                    .font(.body)
                    .minimumScaleFactor(0.1)
                    .padding(.vertical, -25)
                } //end of VStack
                .padding(.horizontal, 10)
                Spacer()
                VStack(alignment: .trailing) {
                  HStack {
                    Text("Your Weather")
                      .font(.largeTitle)
                      .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    Image(systemName: "star")
                      .symbolRenderingMode(.monochrome)
                      .foregroundColor(Color("AccentColor"))
                      .onTapGesture(perform: {
                        showFeedback.toggle()
                      })
                  }
                  .padding(.leading, -5)
                  .padding(.trailing, -5)
                  .padding(.bottom, 1)
                  HStack {
                    if UserDefaults.standard.bool(forKey: "automaticLocation") {
                      Image(systemName: "location.fill")
                        .symbolRenderingMode(.monochrome)
                        .foregroundColor(Color("AccentColor"))
                    } else {
                      Image(systemName: "mappin")
                        .symbolRenderingMode(.monochrome)
                        .foregroundColor(Color("AccentColor"))
                    }
                    Text(currentConditions.current?.location ?? "Mesa")
                      .font(.body)
                      .minimumScaleFactor(0.1)
                    if UserDefaults.standard.bool(forKey: "automaticLocation") {
                      Image(systemName: "arrow.triangle.2.circlepath")
                        .symbolRenderingMode(.monochrome)
                        .foregroundColor(Color("AccentColor"))
                        .onTapGesture {
                          refreshLocation = true
                          showUpdateLocation = true
                        }
                    }
                  } //end of HStack
                  .onTapGesture {
                    showUpdateLocation = true
                  }
                } //end of VStack
                .padding(.horizontal, 10)
              } //end of HStack
              .listRowSeparator(.hidden)
              .listRowBackground(Color.clear)
            } //end of Group
            
            Group {
              if !homeViewModel.todayEvents.isEmpty {
                VStack(alignment: .leading) {
                  Divider()
                    .background(.black)
                    .frame(height: 1)
                  HStack {
                    Text("Today")
                    Spacer()
                    ZStack(alignment: .trailing) {
                      NavigationLink(destination: DailyEvents().environment(\.managedObjectContext, viewCloudContext)) { }
                        .opacity(0)
                      Text("Edit Events")
                        .foregroundColor(Color("AccentColor"))
                    }
                  }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
              }
              ForEach(homeViewModel.todayEvents, id: \.self) { event in
                ZStack(alignment: .leading) {
                  NavigationLink(destination: EventDetail(eventName: event.eventName)) { }
                    .opacity(0)
                  EventListItem(event: event.eventName, startTime: event.startTime, endTime: event.endTime, summary: event.summary, when: event.when)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
              }
              if !homeViewModel.tomorrowEvents.isEmpty {
                VStack(alignment: .leading) {
                  Divider()
                    .background(.black)
                    .frame(height: 1)
                  HStack {
                    Text("Tomorrow")
                    Spacer()
                    ZStack(alignment: .trailing) {
                      NavigationLink(destination: DailyEvents().environment(\.managedObjectContext, viewCloudContext)) { }
                        .opacity(0)
                      Text("Edit Events")
                        .foregroundColor(Color("AccentColor"))
                    }
                  }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
              }
              ForEach(homeViewModel.tomorrowEvents, id: \.self) { event in
                ZStack(alignment: .leading) {
                  NavigationLink(destination: EventDetail(eventName: event.eventName)) { }
                    .opacity(0)
                  EventListItem(event: event.eventName, startTime: event.startTime, endTime: event.endTime, summary: event.summary, when: event.when)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
              }
              if !homeViewModel.laterEvents.isEmpty {
                VStack(alignment: .leading) {
                  Divider()
                    .background(.black)
                    .frame(height: 1)
                  HStack {
                    Text("Later")
                    Spacer()
                    ZStack(alignment: .trailing) {
                      NavigationLink(destination: DailyEvents().environment(\.managedObjectContext, viewCloudContext)) { }
                        .opacity(0)
                      Text("Edit Events")
                        .foregroundColor(Color("AccentColor"))
                    }
                  }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
              }
              ForEach(homeViewModel.laterEvents, id: \.self) { event in
                ZStack(alignment: .leading) {
                  NavigationLink(destination: EventDetail(eventName: event.eventName)) { }
                    .opacity(0)
                  EventListItem(event: event.eventName, startTime: event.startTime, endTime: event.endTime, summary: event.summary, when: event.when)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
              }
              if homeViewModel.todayEvents.isEmpty && homeViewModel.tomorrowEvents.isEmpty && homeViewModel.laterEvents.isEmpty {
                Section() {
                  Divider()
                    .background(.black)
                    .frame(height: 1)
                  HStack {
                    Spacer()
                    Text("No events to show, add some\revents by tapping Add Events. 👇")
                  }
                  ZStack(alignment: .trailing) {
                    NavigationLink(destination: DailyEvents().environment(\.managedObjectContext, viewCloudContext)) { }
                      .opacity(0)
                    Text("Add Events")
                      .foregroundColor(Color("AccentColor"))
                  }
                }
                  .listRowSeparator(.hidden)
                  .listRowBackground(Color.clear)
              }
            } //end of Group
            
            Group {
              VStack(alignment: .leading) {
                Divider()
                  .background(.black)
                  .frame(height: 1)
                Text("Events Imported from your Calendar")
              }
              .listRowSeparator(.hidden)
              .listRowBackground(Color.clear)
              
              ForEach(homeViewModel.importEvents, id: \.self) { event in
                ZStack(alignment: .leading) {
                  NavigationLink(destination: EventDetail(eventName: event.identifier, dailyEvent: false)) { }
                    .opacity(0)
                  EventListItem(event: event.eventName, startTime: event.startTime, endTime: event.endTime, summary: event.summary, when: event.when, calendarEvent: true, isAllDay: event.isAllDay)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
              }

              ZStack(alignment: .leading) {
                NavigationLink(destination: CalendarEvents().environment(\.managedObjectContext, viewCloudContext)) { }
                  .opacity(0)
                VStack(alignment: .leading) {
                  HStack {
                    Text(homeViewModel.importEvents.count > 0 ? "Manage Imported Calendar Events" : "Import Calendar Events")
                      .font(.title2)
                    Image(systemName: "chevron.right")
                      .symbolRenderingMode(.monochrome)
                      .foregroundColor(Color("AccentColor"))
                      .padding(.horizontal, 5)
                  }
                  .padding(.bottom, 1)
                }
                .padding([.leading, .trailing, .top], 10)
                .padding(.bottom, 20)
                .overlay {
                  RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray, lineWidth: 2)
                    .padding(.bottom, 10)
                }
              }
              .listRowSeparator(.hidden)
              .listRowBackground(Color.clear)
            } //end of Group
          } //end of List
          .listStyle(.plain)
          .refreshable {
            Mixpanel.mainInstance().track(event: "Refresh Pulled")
            if globalViewModel.networkOnline {
              homeViewModel.fetchForecast()
              currentConditions.updateCurrent()
              homeViewModel.updateEventList()
            }
          }
          .alert(Text("Location Unavailable"), isPresented: $homeViewModel.showNoLocationAlert, actions: {
            Button("No Thanks") { }
            Button("Enter Location") {
              Task {
                showUpdateLocation = true
              }
            }
          }, message: {
            Text("Since you did not grant location access, you may enter a manual location by tapping the \"Enter Location\" button below, or tapping on the city in the top right of the home screen at any time.")
          })
          .alert(Text("iCloud Login Error"), isPresented: $homeViewModel.showiCloudLoginAlert, actions: {
            Button("Settings") {
              UserDefaults.standard.set(false, forKey: "userNotLoggedIniCloud")
              if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
              }
            }
            Button("Disable Sync") {
              Task {
                await homeViewModel.disableiCloudSync()
              }
            }
          }, message: {
            Text("You may not be logged into iCloud which is only required if you want to sync your events between your own devices, iPhone, iPad, etc. Choose Settings to go there and login to iCloud or choose Disable Sync and this device will not sync your events.")
          })
          .alert(Text("iCloud Fetch Failed"), isPresented: $homeViewModel.showiCloudFetchAlert, actions: {
            Button("OK") {
              UserDefaults.standard.set(false, forKey: "initialFetchFailed")
            }
          }, message: {
            Text("The initial fetch from iCloud failed. Please check your Internet connection, then restart this app to attempt another sync.")
          })
        } //end of VStack
        .navigationBarHidden(true)
      } //end of ZStack
      .sheet(isPresented: $showFeedback) {
        FeedbackModal()
      }
      .sheet(isPresented: $showUpdateLocation) {
        UpdateLocation(refreshLocation: $refreshLocation)
      }
      .onAppear() {
        Mixpanel.mainInstance().track(event: "Home View")
        Analytics.logEvent("View", parameters: ["view_name": "Home"])
        if globalViewModel.returningFromChildView {
          globalViewModel.returningFromChildView = false
          homeViewModel.awaitUpdateNextStartDate()
        }
        guard let _ = UserDefaults.standard.string(forKey: "currentVersion") else {
          let appVersion = globalViewModel.fetchAppVersionNumber()
          let buildNumber = globalViewModel.fetchBuildNumber()
          let currentVersion = "\(appVersion)-\(buildNumber)"
          UserDefaults.standard.set(currentVersion, forKey: "currentVersion")
          return
        }
      }
      .onReceive(self.observer.$enteredForeground) { _ in
        logger.debug("entered foreground")
      }
      .onChange(of: scenePhase) { newPhase in
        if newPhase == .active {
          logger.debug("active")
          if globalViewModel.networkOnline {
            homeViewModel.fetchForecast()
            currentConditions.updateCurrent()
          }
          homeViewModel.awaitUpdateNextStartDate()
          if UserDefaults.standard.bool(forKey: "userNotLoggedIniCloud") {
            homeViewModel.showiCloudLoginAlert = true
          }
          if UserDefaults.standard.bool(forKey: "initialFetchFailed") {
            homeViewModel.showiCloudFetchAlert = true
          }
          if locationViewModel.authorizationStatus == .notDetermined {
            locationViewModel.requestPermission()
          }
        } else if newPhase == .inactive {
          logger.debug("inactive")
        } else if newPhase == .background {
          logger.debug("background")
        }
      }
    } //end of NavigationStack
    .accentColor(Color("AccentColor"))
  }
}

//struct ListView_Previews: PreviewProvider {
//  static var previews: some View {
//    Home(viewContext: viewContext)
//  }
//}
