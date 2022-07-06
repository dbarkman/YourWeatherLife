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

  @ObservedObject var observer = Observer()
  @ObservedObject private var globalViewModel: GlobalViewModel
  
  @StateObject private var currentConditions = CurrentConditionsViewModel()

  @State private var fetchAllData = false
  
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
            HStack {
              VStack(alignment: .leading) {
                HStack {
                  Text(currentConditions.current?.temperature ?? "--")
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
                Text("Your Weather")
                  .font(.largeTitle)
                  .lineLimit(1)
                  .minimumScaleFactor(0.1)
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
            .padding(.bottom, 20)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)

            ForEach(globalViewModel.events, id: \.self) { event in
              ZStack(alignment: .leading) {
                NavigationLink(destination: EventDetail(event: event.event)) { }
                  .opacity(0)
                EventListItem(event: event.event, startTime: event.startTime, endTime: event.endTime, summary: event.summary, tomorrow: event.tomorrow)
              }
              .listRowSeparator(.hidden)
              .listRowBackground(Color.clear)
            }
            
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
              NavigationLink(destination: EventDetail(event: "Taco Tuesday")) { }
                .opacity(0)
              EventListCalendarItem(title: "Taco Tuesday Happy Hour on June 21", startTemp: "83°", startTime: "6p", endTemp: "75°", endTime: "9p", aroundSunrise: false, sunriseTemp: "", sunriseTime: "", aroundSunset: true, sunsetTemp: "76°", sunsetTime: "8:15p", precipitation: false, precipitationType: "", precipitationTime: "", precipitationPercent: "", eventWeatherSummary: "Cool and clear with no chance for rain")
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            ZStack(alignment: .leading) {
              NavigationLink(destination: EventDetail(event: "Group Hike")) { }
                .opacity(0)
              EventListCalendarItem(title: "Group hike on June 25", startTemp: "65°", startTime: "6:30a", endTemp: "72°", endTime: "9a", aroundSunrise: true, sunriseTemp: "67°", sunriseTime: "7:10a", aroundSunset: false, sunsetTemp: "", sunsetTime: "", precipitation: true, precipitationType: "rain", precipitationTime: "8a", precipitationPercent: "65%", eventWeatherSummary: "Cold and cloudy with a good chance of rain")
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
          } //end of List
          .listStyle(.plain)
          .refreshable {
            Mixpanel.mainInstance().track(event: "Refresh Pulled")
            await updateData()
          }
        }
        .navigationBarHidden(true)
        
        NavigationLink(destination: DailyEvents(), isActive: $globalViewModel.isShowingDailyEvents) { }
      } //end of VStack
      .task {
        if fetchAllData {
          await updateData()
        }
      }
      .onAppear() {
        Mixpanel.mainInstance().track(event: "Home View")
      }
      .onReceive(self.observer.$enteredForeground) { _ in
        Task {
          await updateData()
        }
      }
    } //end of NavigationView
    .environmentObject(globalViewModel)
  }
  
  private func updateData() async {
    await currentConditions.fetchCurrentWeather()
    await GetAllData.shared.getAllData()
    await globalViewModel.createEventList()
    fetchAllData = true
  }
}

//struct ListView_Previews: PreviewProvider {
//  @Environment(\.managedObjectContext) private var viewContext
//  static var previews: some View {
//    Home(viewContext: viewContext)
//  }
//}
