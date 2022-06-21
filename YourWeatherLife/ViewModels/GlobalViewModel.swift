//
//  GlobalViewModel.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/11/22.
//

import Foundation
import Mixpanel
import OSLog

class GlobalViewModel: ObservableObject {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "GlobalViewModel")
  
  var container = LocalPersistenceController.shared.container
  var data = Data()

  //MARK: Home
  
  @Published public var currentTemp = "--"
  @Published public var currentConditions = "unkown"
  @Published public var currentConditionIconURL = ""
  
  func fetchCurrentWeather() async {
    if UserDefaults.standard.bool(forKey: "apisFetched") {
      let api = fetchPrimaryAPIFromLocal()
      guard !api.urlBase.isEmpty, !api.apiKey.isEmpty else { return }
      let url = api.urlBase + "/current.json" + "?key=" + api.apiKey + "&q=85215"
      let urlRequest = URLRequest(url: URL(string: url)!)
      logger.debug("api url: \(url)")
      do {
        guard let (data, response) = try? await URLSession.shared.data(for: urlRequest), let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200
        else {
          logger.debug("Failed to received valid response and/or data.")
          throw YWLError.missingData
        }
        self.data = data
      } catch {
        logger.error("Could not fetch current conditions. ⛈")
      }
      
      do {
        let jsonDecoder = JSONDecoder()
        do {
          let currentDecoder = try jsonDecoder.decode(CurrentDecoder.self, from: data)
          DispatchQueue.main.async {
            let formatter = MeasurementFormatter()
            formatter.unitStyle = .short
            formatter.numberFormatter.roundingMode = .halfUp
            formatter.numberFormatter.maximumFractionDigits = 0
            let measurement = Measurement(value: currentDecoder.current.temp_c, unit: UnitTemperature.celsius)
            self.currentTemp = formatter.string(from: measurement)
            self.currentConditions = currentDecoder.current.condition.text
            self.currentConditionIconURL = currentDecoder.current.condition.icon
          }
        } catch {
          logger.error("Could not decode current conditions. 🌧")
        }
      }
      
    } else {
      Task {
        await fetchAPIsFromCloud()
        UserDefaults.standard.set(true, forKey: "apisFetched")
        await fetchCurrentWeather()
      }
    }
  }
  
  //MARK: EditEventPencil
  
  @Published public var isShowingDailyEvents = false
  
  func showDailyEvents() {
    Mixpanel.mainInstance().track(event: "Showing DailyEvents")
    isShowingDailyEvents.toggle()
  }
  
  //MARK: Fetching APIs
  
  private func fetchAPIsFromCloud() async {
    do {
      try await APIsProvider.shared.fetchAPIs()
    } catch {
      logger.error("Error loading APIs: \(error.localizedDescription)")
    }
  }
  
  private func fetchPrimaryAPIFromLocal () -> API {
    let request = API.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(keyPath: \API.priority, ascending: true)]
    request.fetchLimit = 1
    do {
      if let api = try container.viewContext.fetch(request).first as? API {
        return api
      }
    } catch {
      logger.debug("Fetch failed 😭")
    }
    return API()
  }
  
}
