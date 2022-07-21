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

struct Home: View {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "Home")
  
  @Environment(\.scenePhase) var scenePhase
  @Environment(\.managedObjectContext) private var viewContext
  @Environment(\.managedObjectContext) private var viewCloudContext

  @ObservedObject var observer = Observer()
  @ObservedObject private var globalViewModel: GlobalViewModel
  
  @StateObject private var homeViewModel = HomeViewModel()
  @StateObject private var locationViewModel = LocationViewModel()
  @StateObject private var currentConditions = CurrentConditionsViewModel()

  @State var showFeedback = false
  
  init(viewContext: NSManagedObjectContext, viewCloudContext: NSManagedObjectContext) {
    globalViewModel = GlobalViewModel(viewContext: viewContext, viewCloudContext: viewCloudContext)
  }
  
  var body: some View {
    
    UITableView.appearance().backgroundColor = .clear
    
    return NavigationView {
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
                    Image(systemName: "location.fill")
                      .symbolRenderingMode(.monochrome)
                      .foregroundColor(Color("AccentColor"))
                    Text(currentConditions.current?.location ?? "Mesa")
                      .font(.body)
                      .minimumScaleFactor(0.1)
                    Image(systemName: "chevron.down")
                      .symbolRenderingMode(.monochrome)
                      .foregroundColor(Color("AccentColor"))

                  } //end of HStack
                } //end of VStack
                .padding(.horizontal, 10)
              } //end of HStack
//              .padding(.bottom, 20)
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
                    Text("Edit Events")
                      .foregroundColor(Color("AccentColor"))
                      .onTapGesture {
                        globalViewModel.showDailyEvents()
                      }
                  }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
              }
              ForEach(homeViewModel.todayEvents, id: \.self) { event in
                ZStack(alignment: .leading) {
                  NavigationLink(destination: EventDetail(event: event)) { }
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
                    Text("Edit Events")
                      .foregroundColor(Color("AccentColor"))
                      .onTapGesture {
                        globalViewModel.showDailyEvents()
                      }
                  }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
              }
              ForEach(homeViewModel.tomorrowEvents, id: \.self) { event in
                ZStack(alignment: .leading) {
                  NavigationLink(destination: EventDetail(event: event)) { }
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
                    Text("Edit Events")
                      .foregroundColor(Color("AccentColor"))
                      .onTapGesture {
                        globalViewModel.showDailyEvents()
                      }
                  }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
              }
              ForEach(homeViewModel.laterEvents, id: \.self) { event in
                ZStack(alignment: .leading) {
                  NavigationLink(destination: EventDetail(event: event)) { }
                    .opacity(0)
                  EventListItem(event: event.eventName, startTime: event.startTime, endTime: event.endTime, summary: event.summary, when: event.when)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
              }
              if homeViewModel.todayEvents.isEmpty && homeViewModel.tomorrowEvents.isEmpty && homeViewModel.laterEvents.isEmpty {
                Text("Your saved events are syncing from iCloud and should display momentarily.")
                  .listRowSeparator(.hidden)
                  .listRowBackground(Color.clear)
              }
            } //end of Group
            
            Group {
              VStack {
                Divider()
                  .background(.black)
                  .frame(height: 1)
              }
              .listRowSeparator(.hidden)
              .listRowBackground(Color.clear)

              ZStack(alignment: .leading) {
                NavigationLink(destination: DayDetail(dates: [globalViewModel.today]).navigationTitle("Today")) { }
                  .opacity(0)
                EventListToday()
              }
              .listRowSeparator(.hidden)
              .listRowBackground(Color.clear)
              
              ZStack(alignment: .leading) {
                NavigationLink(destination: DayDetail(dates: globalViewModel.weekend).navigationTitle("Weekend")) { }
                  .opacity(0)
                EventListWeekend()
              }
              .listRowSeparator(.hidden)
              .listRowBackground(Color.clear)
              
              ZStack(alignment: .leading) {
                NavigationLink(destination: DayForecast()) { }
                  .opacity(0)
                VStack(alignment: .leading) {
                  HStack {
                    Text("14 Day Forecast")
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
              
              ZStack(alignment: .leading) {
                NavigationLink(destination: HourlyForecast()) { }
                  .opacity(0)
                VStack(alignment: .leading) {
                  HStack {
                    Text("336 Hour Forecast")
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
            
            Group {
              VStack(alignment: .leading) {
                Divider()
                  .background(.black)
                Text("Fictional Events from Your Calendar")
              }
              .listRowSeparator(.hidden)
              .listRowBackground(Color.clear)
              
              ZStack(alignment: .leading) {
                EventListCalendarItem(title: "Taco Tuesday Happy Hour on June 21", startTemp: "83°", startTime: "6p", endTemp: "75°", endTime: "9p", aroundSunrise: false, sunriseTemp: "", sunriseTime: "", aroundSunset: true, sunsetTemp: "76°", sunsetTime: "8:15p", precipitation: false, precipitationType: "", precipitationTime: "", precipitationPercent: "", eventWeatherSummary: "Cool and clear with no chance for rain")
              }
              .listRowSeparator(.hidden)
              .listRowBackground(Color.clear)
              
              ZStack(alignment: .leading) {
                EventListCalendarItem(title: "Group hike on June 25", startTemp: "65°", startTime: "6:30a", endTemp: "72°", endTime: "9a", aroundSunrise: true, sunriseTemp: "67°", sunriseTime: "7:10a", aroundSunset: false, sunsetTemp: "", sunsetTime: "", precipitation: true, precipitationType: "rain", precipitationTime: "8a", precipitationPercent: "65%", eventWeatherSummary: "Cold and cloudy with a good chance of rain")
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
            }
            homeViewModel.awaitUpdateNextStartDate()
          }
          .alert(Text("iCloud Login Error"), isPresented: $homeViewModel.showiCloudLoginAlert, actions: {
            Button("Settings") {
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
        
        NavigationLink(destination: DailyEvents().environment(\.managedObjectContext, CloudPersistenceController.shared.container.viewContext), isActive: $globalViewModel.isShowingDailyEvents) { }
      } //end of ZStack
      .sheet(isPresented: $showFeedback) {
        FeedbackModal()
      }
      .onAppear() {
        Mixpanel.mainInstance().track(event: "Home View")
        globalViewModel.countEverything()
        if globalViewModel.returningFromChildView {
          globalViewModel.returningFromChildView = false
          homeViewModel.awaitUpdateNextStartDate()
        }
      }
      .onReceive(self.observer.$enteredForeground) { _ in
        locationViewModel.requestPermission()
        homeViewModel.globalViewModel = globalViewModel
        currentConditions.globalViewModel = globalViewModel
      }
      .onChange(of: scenePhase) { newPhase in
        if newPhase == .active {
          logger.debug("active")
          if globalViewModel.networkOnline {
            homeViewModel.fetchForecast()
            currentConditions.updateCurrent()
          }
          if UserDefaults.standard.bool(forKey: "userNotLoggedIniCloud") {
            homeViewModel.showiCloudLoginAlert = true
          }
          if UserDefaults.standard.bool(forKey: "initialFetchFailed") {
            homeViewModel.showiCloudFetchAlert = true
          }
        } else if newPhase == .inactive {
          logger.debug("inactive")
        } else if newPhase == .background {
          logger.debug("background")
        }
      }
    } //end of NavigationView
    .environmentObject(globalViewModel)
  }
}

//struct ListView_Previews: PreviewProvider {
//  @Environment(\.managedObjectContext) private var viewContext
//  static var previews: some View {
//    Home(viewContext: viewContext)
//  }
//}
