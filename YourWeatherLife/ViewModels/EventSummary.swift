//
//  EventSummary.swift
//  YourWeatherLife
//
//  Created by David Barkman on 7/2/22.
//

import Foundation

class EventSummary {
  
  //todos
  //sleet, hurricanes, tornados, dust, windchill

  //summaries
  var tempDescription = ""
  var tempConjunction = ""
  var tempChangeDescription = ""
  var tempActual = ""
  var conditionDescription = ""
  var windDescription = ""
  var humidityDescription = ""
  var rainDescription = ""
  var snowDescription = ""
  var thunderstormDescription = ""
  var uvDescription = ""
  
  var conditionArray = [String]()
  var cloudArray = [Int]()
  var rainArray = [Int]()
  var snowArray = [Int]()

  func creatSummary(hoursForecast: [TGWForecastHour]) -> String {
    
    //data
    var countI = 0
    var countD = 0.0
    var averageTemp = 0.0
    var firstTemp = 0.0
    var lastTemp = 0.0
    var heatIndexAverage = 0.0
    var windAverage = 0.0
    
    var averageUV = 0.0
    
    for hour in hoursForecast {
      let temp = hour.temp_c
      averageTemp += temp
      if countI == 0 { firstTemp = temp }
      lastTemp = temp
      conditionArray.append(hour.condition_text ?? "")
      cloudArray.append(Int(hour.cloud))
      windAverage += hour.wind_mph
      heatIndexAverage += hour.heatindex_c
      rainArray.append(Int(hour.chance_of_rain))
      snowArray.append(Int(hour.chance_of_snow))

      averageUV += hour.uv
      
      countD += 1
      countI += 1
    }
    
    let temp = averageTemp / countD
    tempActual = String(Formatters.format(temp: temp, from: .celsius))
    let tempChange = firstTemp - lastTemp
    if tempChange >= 10 { tempChangeDescription = "temps falling" }
    if tempChange <= -10 { tempChangeDescription = "temps rising" }
    let heatIndex = heatIndexAverage / countD
    let wind = windAverage / countD
    
    let uv = Int(averageUV / countD)
    if uv > 5 { uvDescription = ", with a UV index of \(uv)" }
    
    setTempDescriptionSummary(temp: temp)
    setConditionDescription()
    setWindDescription(windSpeed: wind)
    setHumidityDescription(temp: temp, heatIndex: heatIndex)
    setPrecipDescription()
    return buildFinalSummary()
  }
  
  private func setTempDescriptionSummary(temp: Double) {
    switch true {
      case temp > 54.4:
        tempDescription = "blazing hot"
        tempConjunction = tempChangeDescription == "temps falling" ? "but" : "and"
      case temp > 43.3:
        tempDescription = "scorching hot"
        tempConjunction = tempChangeDescription == "temps falling" ? "but" : "and"
      case temp > 32.2:
        tempDescription = "hot"
        tempConjunction = tempChangeDescription == "temps falling" ? "but" : "and"
      case temp > 21.1:
        tempDescription = "warm"
        tempConjunction = tempChangeDescription == "temps falling" ? "but" : "and"
      case temp > 10:
        tempDescription = "cool"
        tempConjunction = tempChangeDescription == "temps rising" ? "but" : "and"
      case temp > 0:
        tempDescription = "cold"
        tempConjunction = tempChangeDescription == "temps rising" ? "but" : "and"
      case temp > -12.2:
        tempDescription = "freezing"
        tempConjunction = tempChangeDescription == "temps rising" ? "but" : "and"
      default:
        tempDescription = "bitter freezing"
        tempConjunction = tempChangeDescription == "temps rising" ? "but" : "and"
    }
  }
  
  private func setConditionDescription() {
    var description = ""
    var isDiff = false
    var currentCondition = ""
    for condition in conditionArray {
      if condition.contains("thunder") { thunderstormDescription = " with thunderstorms possible" }
      if !currentCondition.isEmpty {
        isDiff = currentCondition == condition ? false : true
      }
      currentCondition = condition
    }
    if !isDiff {
      description = currentCondition.lowercased()
    } else {
      var count = 0
      var averageCloud = 0
      for cloud in cloudArray {
        count += 1
        averageCloud += cloud
      }
      let cloud = averageCloud / count
      switch true {
        case cloud >= 75:
          description = "cloudy"
        case cloud >= 50:
          description = "mostly cloudy"
        case cloud >= 25:
          description = "partly cloudy"
        default:
          description = "clear"
      }
    }
    description = description == "light rain shower" ? description + "s" : description
    conditionDescription = description
  }
  
  private func setWindDescription(windSpeed: Double) {
    var wind = ""
    switch true {
      case windSpeed >= 30:
        wind = "gusty"
      case windSpeed >= 15:
        wind = "windy"
      case windSpeed >= 5:
        wind = "breezy"
      default:
        wind = ""
    }
    if !wind.isEmpty {
      windDescription = wind
    }
  }
  
  private func setHumidityDescription(temp: Double, heatIndex: Double) {
    if temp > 32.2 && heatIndex < temp {
      humidityDescription = " and dry"
      return
    }
    if temp < 25.36 || heatIndex < temp {
      humidityDescription = ""
      return
    }
    switch true {
      case heatIndex > 55.5:
        humidityDescription = " and sweltering"
      case heatIndex > 41.1:
        humidityDescription = " and sticky"
      case heatIndex > 32.7:
        humidityDescription = " and muggy"
      default:
        humidityDescription = " and humid"
    }
  }
  
  private func setPrecipDescription() {
    var count = 0
    var rainAverage = 0
    var snowAverage = 0
    var firstRain = 0
    var lastRain = 0
    var firstSnow = 0
    var lastSnow = 0
    for rain in rainArray {
      if count == 0 { firstRain = rain }
      lastRain = rain
      rainAverage += rain
      count += 1
    }
    let rain = rainAverage / count
    count = 0
    for snow in snowArray {
      if count == 0 { firstSnow = snow }
      lastSnow = snow
      snowAverage += snow
      count += 1
    }
    let snow = snowAverage / count

    if rain < 25 && snow < 25 {
      rainDescription = ""
      snowDescription = ""
      return
    }
    
    if rain >= 25 {
      rainDescription = " with a \(rain)% chance of rain"
      let rainDiff = firstRain - lastRain
      if rainDiff >= 50 { rainDescription = " with the chance of rain decreasing from \(firstRain)%" }
      if rainDiff <= -50 { rainDescription = " with the chance of rain increasing to \(lastRain)%" }
    }
    if snow >= 25 {
      snowDescription += !rainDescription.isEmpty ? " and " : " with "
      snowDescription = "a \(rain)% chance of snow"
      let snowDiff = firstSnow - lastSnow
      if snowDiff >= 50 {
        snowDescription += !rainDescription.isEmpty ? " and " : " with "
        snowDescription = "a chance of snow decreasing from \(firstSnow)%"
      }
      if snowDiff <= -50 {
        snowDescription += !rainDescription.isEmpty ? " and " : " with "
        snowDescription = "a chance of snow increasing to \(lastSnow)%"
      }
    }
  }
  
  private func buildFinalSummary() -> String {
    var windConjunction = humidityDescription.isEmpty ? " and " : ", "
    windConjunction = windDescription.isEmpty ? "" : windConjunction
    tempConjunction = tempChangeDescription.isEmpty ? "" : tempConjunction
    
    let finalSummary = tempActual + " " + tempDescription + tempConjunction + tempChangeDescription + ", " + conditionDescription + windConjunction + windDescription + humidityDescription + rainDescription + snowDescription + thunderstormDescription + uvDescription
    return finalSummary
  }
}

//Formatters.format(temp: hour.temp_c, from: .celsius)
//tempDesc and tempChangeDesc at temp, condition, windDesc, humidityDesc, precip
// - if tempDesc and tempChangeDesc opposite, use "but", otherwise use "and"
//Hot at 102°, mostly sunny
//Hot at 102°, partly cloudy, breezy
//Warm at 85°, sunny and breezy, humid with a 40% chance of rain
//Hot "but" cooling at 100°, clear and breezy, dry with 40% chance of "rain", and a UV index of 5
//tempDescription = Hot
//conjunction = but
//tempChangeDescription = cooling
//tempActual = at 100°,
//conditionDescription = clear
//windDescription = and breezy
//humidityDescription = , dry
//precipDescription = with 40% chance of
//precipTypeDescription = rain
//thunderstormDescription = with thunderstorms possible
//clear and breezy
//clear, breezy and dry
//clear and dry
