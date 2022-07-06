//
//  Formatters.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/21/22.
//

import Foundation

struct Formatters {
  
  static func format(temp: Double, from unit: UnitTemperature) -> String {
    let formatter = MeasurementFormatter()
    formatter.unitStyle = .short
    formatter.numberFormatter.roundingMode = .halfUp
    formatter.numberFormatter.maximumFractionDigits = 0
    let measurement = Measurement(value: temp, unit: unit)
    return formatter.string(from: measurement)
  }
  
  static func format(speed: Double, from unit: UnitSpeed) -> String {
    let formatter = MeasurementFormatter()
    formatter.unitStyle = .medium
    formatter.numberFormatter.roundingMode = .halfUp
    formatter.numberFormatter.maximumFractionDigits = 0
    let measurement = Measurement(value: speed, unit: unit)
    return formatter.string(from: measurement)
  }
  
  static func format(length: Double, from unit: UnitLength) -> String {
    let formatter = MeasurementFormatter()
    formatter.unitStyle = .medium
    formatter.numberFormatter.roundingMode = .halfUp
    formatter.numberFormatter.maximumFractionDigits = 0
    let measurement = Measurement(value: length, unit: unit)
    return formatter.string(from: measurement)
  }
  
  static func format(pressure: Double, from unit: UnitPressure) -> String {
    let formatter = MeasurementFormatter()
    formatter.unitStyle = .short
    formatter.numberFormatter.roundingMode = .halfUp
    formatter.numberFormatter.maximumFractionDigits = 2
    let measurement = Measurement(value: pressure, unit: unit)
    return formatter.string(from: measurement)
  }
}
