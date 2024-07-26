//
//  AsyncAPI.swift
//  YourWeatherLife
//
//  Created by David Barkman on 3/19/23.
//

import Foundation
import Mixpanel
import OSLog

struct AsyncAPI {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "AsyncAPI")
  
  static let shared = AsyncAPI()
  
  private init() { }
  
  func getLatLong(manualLocation: String) async -> String? {
    var urlString = await wxa.shared.getSearchURL()
    urlString += "&q=" + manualLocation
    logger.debug("URL: \(urlString)")
    guard let url = URL(string: urlString) else {
      logger.error("Failed to build URL. 😭")
      return nil
    }
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    do {
      let (data, response) = try await URLSession.shared.data(for: request)
      if let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode == 200 {
          let jsonDecoder = JSONDecoder()
          do {
            let searchResponse = try jsonDecoder.decode([SearchResponse].self, from: data)
            if let lat = searchResponse.first?.lat, let long = searchResponse.first?.long {
              UserDefaults.standard.set(lat, forKey: "lat")
              UserDefaults.standard.set(long, forKey: "long")
              return "\(lat),\(long)"
            }
          } catch {
            logger.error("Failed to decode data when fetching lat/long. 😭 \(error.localizedDescription)")
          }
        } else { //response was not 200
          logger.error("HTTP response was not 200 when fetching lat/long. 😭 Response code: \(httpResponse.statusCode), Response description: \(httpResponse.description)")
        }
      } else {
        logger.error("Failed to parse http response when fetching lat/long. 😭")
      }
    } catch {
      logger.error("Failed to fetch data when fetching lat/long. 😭 \(error.localizedDescription)")
    }
    return nil
  }
  
  func getZoneId() async {
    var urlString = await wxa.shared.getNWSPointsURL()
    if !UserDefaults.standard.bool(forKey: "automaticLocation") {
      var manualLocationData = "98034"
      if let location = UserDefaults.standard.string(forKey: "manualLocationData") {
        manualLocationData = location
      }
      if let latLong = await getLatLong(manualLocation: manualLocationData) {
        urlString += latLong
      }
    } else {
      urlString = await wxa.shared.getNWSPointsURLwithLocation()
    }
    logger.debug("URL: \(urlString)")
    guard let url = URL(string: urlString) else {
      logger.error("Failed to build URL. 😭")
      return
    }
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    do {
      let (data, response) = try await URLSession.shared.data(for: request)
      if let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode == 200 {
          let jsonDecoder = JSONDecoder()
          do {
            let location = try jsonDecoder.decode(NWSPointsResponse.self, from: data)
            if let county = location.properties?.county {
              let zoneId = county.components(separatedBy: "/").last
              UserDefaults.standard.set(zoneId, forKey: "zone")
            }
            if let city = location.properties?.relativeLocation?.properties?.city {
              UserDefaults.standard.set(city, forKey: "city")
            }
            if let state = location.properties?.relativeLocation?.properties?.state {
              UserDefaults.standard.set(state, forKey: "area")
            }
          } catch {
            logger.error("Failed to decode data when fetching zone. 😭 \(error.localizedDescription)")
          }
        } else { //response was not 200
          logger.error("HTTP response was not 200 when fetching zone. 😭 Response code: \(httpResponse.statusCode), Response description: \(httpResponse.description)")
        }
      } else {
        logger.error("Failed to parse http response when fetching zone. 😭")
      }
    } catch {
      logger.error("Failed to fetch data when fetching zone. 😭 \(error.localizedDescription)")
    }
  }
  
  func getAlerts(location: Int) async -> AlertsResponse? {
    var decodedResponse: AlertsResponse?
    
    let apiKey = APISettings.shared.fetchAPISettings().apiKey
    let secretKey = APISettings.shared.fetchAPISettings().secretKey
    let signature = CryptoUtilities.shared.signRequest(input: apiKey, secretKey: secretKey)
    let urlBase = APISettings.shared.fetchAPISettings().urlBase
    let zone = UserDefaults.standard.string(forKey: "zone") ?? "WAC033"
    let area = UserDefaults.standard.string(forKey: "area") ?? "WA"

    var urlString = urlBase + "/api/alerts"
    urlString += addVersionInfo(urlString: urlString)
    if location == 0 {
      urlString += "&zone=" + zone
    } else if location == 1 {
      urlString += "&area=" + area
    }
    logger.debug("URL: \(urlString)")
    guard let url = URL(string: urlString) else { return nil }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue(apiKey, forHTTPHeaderField: "apiKey")
    request.setValue(signature, forHTTPHeaderField: "signature")

    do {
      let (data, response) = try await URLSession.shared.data(for: request)
      if let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode == 200 {
          let jsonDecoder = JSONDecoder()

          do {
            decodedResponse = try jsonDecoder.decode(AlertsResponse.self, from: data)
          } catch {
            logger.error("Failed to decode data when fetching alerts. 😭 \(error.localizedDescription)")
          }
        } else { //response was not 200
          logger.error("HTTP response was not 200 when fetching alerts. 😭 Response code: \(httpResponse.statusCode), Response description: \(httpResponse.description)")
          return decodedResponse
        }
      } else {
        logger.error("Failed to parse http response when fetching alerts. 😭")
        return nil
      }
    } catch {
      logger.error("Failed to fetch data when fetching alerts. 😭 \(error.localizedDescription)")
    }
    return decodedResponse
  }
  
  func saveToken(token: String, debug: Int) async {
    
    let apiKey = APISettings.shared.fetchAPISettings().apiKey
    let secretKey = APISettings.shared.fetchAPISettings().secretKey
    let signature = CryptoUtilities.shared.signRequest(input: apiKey, secretKey: secretKey)
    let urlBase = APISettings.shared.fetchAPISettings().urlBase
    
    var urlString = urlBase + "/api/token"
    urlString += addVersionInfo(urlString: urlString)
    logger.debug("URL: \(urlString)")
    guard let url = URL(string: urlString) else { return }
    
    var httpBody = "token=\(token)&debug=\(debug)"
    let sendPush = UserDefaults.standard.bool(forKey: "sendPush") == true ? 1 : 0
    let sendAll = UserDefaults.standard.bool(forKey: "sendAll") == true ? 1 : 0
    let sendArea = UserDefaults.standard.bool(forKey: "sendArea") == true ? 1 : 0
    let zone = UserDefaults.standard.string(forKey: "zone") ?? "WAC033"
    let area = UserDefaults.standard.string(forKey: "area") ?? "WA"
    httpBody += "&sendPush=\(sendPush)&sendAll=\(sendAll)&sendArea=\(sendArea)&zone=\(zone)&area=\(area)"
    
    if let distinctId = UserDefaults.standard.string(forKey: "distinctId") {
      httpBody += "&uuid=\(distinctId)"
    } else {
      let distinctId = UUID().uuidString
      UserDefaults.standard.set(distinctId, forKey: "distinctId")
      httpBody += "&uuid=\(distinctId)"
      Mixpanel.mainInstance().identify(distinctId: distinctId)
      Mixpanel.mainInstance().people.set(properties: ["$name":distinctId])
    }
    logger.debug("httpBody: \(httpBody)")
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue(apiKey, forHTTPHeaderField: "apiKey")
    request.setValue(signature, forHTTPHeaderField: "signature")
    request.httpBody = httpBody.data(using: String.Encoding.utf8)
    
    do {
      let (_, response) = try await URLSession.shared.data(for: request)
      if let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
          logger.error("HTTP response was not 200 or 201 when saving token. 😭 Response code: \(httpResponse.statusCode), Response description: \(httpResponse.description)")
        }
      }
    } catch {
      logger.error("Failed to fetch data when fetching alerts. 😭 \(error.localizedDescription)")
    }
    return
  }
  
  func addVersionInfo(urlString: String) -> String {
    let appVersion = GlobalViewModel.shared.fetchAppVersionNumber()
    let buildNumber = GlobalViewModel.shared.fetchBuildNumber()
    let osVersion = GlobalViewModel.shared.fetchOsVersion()
    let device = GlobalViewModel.shared.fetchDevice()
    return "?appVersion=\(appVersion).\(buildNumber)&osVersion=\(osVersion)&device=\(device)"
  }
  
}
