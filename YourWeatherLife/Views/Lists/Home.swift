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
  
  @Environment(\.managedObjectContext) private var viewContext
  @Environment(\.managedObjectContext) private var viewCloudContext
  @Environment(\.scenePhase) var scenePhase

  @ObservedObject var observer = Observer()
  @ObservedObject private var globalViewModel: GlobalViewModel
  
  @StateObject private var homeViewModel = HomeViewModel()
  @StateObject private var locationViewModel = LocationViewModel()
  @StateObject private var currentConditions = CurrentConditionsViewModel()

  @State var showingFeedback = false
  
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
                      .foregroundColor(Color.white)
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
                    Button(action: {
                      showingFeedback.toggle()
                    }) {
                      Label("", systemImage: "star")
                    }
                    .sheet(isPresented: $showingFeedback) {
                      FeedbackModal()
                    }
                    .padding(.leading, -5)
                    .padding(.trailing, -15)
                  }
                  HStack {
                    Image(systemName: "location.fill")
                      .symbolRenderingMode(.monochrome)
                      .foregroundColor(Color.accentColor)
                    Text(currentConditions.current?.location ?? "Mesa")
                      .font(.body)
                      .minimumScaleFactor(0.1)
                    Image(systemName: "chevron.down")
                      .symbolRenderingMode(.monochrome)
                      .foregroundColor(Color.accentColor)

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
                  Text("Today")
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
              }
              ForEach(homeViewModel.todayEvents, id: \.self) { event in
                ZStack(alignment: .leading) {
                  NavigationLink(destination: EventDetail(eventForecast: event)) { }
                    .opacity(0)
                  EventListItem(event: event.eventName, startTime: event.startTime, endTime: event.endTime, summary: event.summary, tomorrow: event.tomorrow)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
              }
              if !homeViewModel.tomorrowEvents.isEmpty {
                VStack(alignment: .leading) {
                  Divider()
                    .background(.black)
                    .frame(height: 1)
                  Text("Tomorrow")
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
              }
              ForEach(homeViewModel.tomorrowEvents, id: \.self) { event in
                ZStack(alignment: .leading) {
                  NavigationLink(destination: EventDetail(eventForecast: event)) { }
                    .opacity(0)
                  EventListItem(event: event.eventName, startTime: event.startTime, endTime: event.endTime, summary: event.summary, tomorrow: event.tomorrow)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
              }
              if homeViewModel.todayEvents.isEmpty && homeViewModel.tomorrowEvents.isEmpty {
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
                      .foregroundColor(Color.accentColor)
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
                      .foregroundColor(Color.accentColor)
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
          }
          .alert(Text("iCloud Login Error"), isPresented: $homeViewModel.showiCloudLoginAlert, actions: {
            Button("Settings") {
              UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            }
            Button("Disable Sync") {
              Task {
                await homeViewModel.disableiCloudSync()
              }
            }
          }, message: {
            Text("You may not be logged into iCloud which is only required if you want to sync your events between your own devices, iPhone, iPad, etc. Choose Settings to go there and login to iCloud or choose Disable Sync and this device will not sync your events.")
          })
          .alert(Text("iCloud Fetch Failed"), isPresented: $homeViewModel.showiCloudLoginAlert, actions: {
            Button("OK") {
              UserDefaults.standard.set(false, forKey: "initialFetchFailed")
            }
          }, message: {
            Text("The initial fetch from iCloud failed. Please check your Internet connection, then restart this app to attempt another sync.")
          })
        } //end of VStack
        .navigationBarHidden(true)
        
        NavigationLink(destination: DailyEvents(), isActive: $globalViewModel.isShowingDailyEvents) { }
      } //end of ZStack
      .onAppear() {
        Mixpanel.mainInstance().track(event: "Home View")
        if UserDefaults.standard.bool(forKey: "userNotLoggedIniCloud") {
          homeViewModel.showiCloudLoginAlert = true
        }
      }
      .onReceive(self.observer.$enteredForeground) { _ in
        homeViewModel.globalViewModel = globalViewModel
        currentConditions.globalViewModel = globalViewModel
      }
      .onChange(of: scenePhase) { newPhase in
        if newPhase == .active {
          if globalViewModel.networkOnline {
            homeViewModel.fetchForecast()
            currentConditions.updateCurrent()
          }
        } else if newPhase == .inactive {
        } else if newPhase == .background {
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
