//
//  AOWM_Icon.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/26/22.
//

import Foundation
import UIKit

struct AOWM_Icon {
  
  static func getCurrentConditionsIcon(iconId: Int, isDay: Bool) -> String {
    var iconName = "day/113"
    let name = getIconName(iconId: iconId)
    iconName = isDay ? "day/" + name : "night/" + name
    return iconName
  }
  
  static private func getIconName(iconId: Int) -> String {
    var icon = ""
    switch iconId {
      case 801, 802:
        icon = "116"
      case 721, 731, 751, 761, 803:
        icon = "119"
      case 711, 762, 804:
        icon = "122"
      case 701:
        icon = "143"
      case 500, 520, 531:
        icon = "176"
      case 600, 620:
        icon = "179"
      case 615:
        icon = "182"
      case 200, 210, 221, 230:
        icon = "200"
      case 621:
        icon = "227"
      case 622:
        icon = "230"
      case 741:
        icon = "248"
      case 300, 301, 302, 310, 311, 312, 313, 314, 321:
        icon = "263"
      case 501:
        icon = "296"
      case 521, 522:
        icon = "305"
      case 502, 503:
        icon = "308"
      case 511:
        icon = "311"
      case 616:
        icon = "317"
      case 601:
        icon = "326"
      case 602:
        icon = "338"
      case 611:
        icon = "350"
      case 504, 771, 781:
        icon = "359"
      case 612:
        icon = "374"
      case 613:
        icon = "377"
      case 201, 202, 211, 212, 231, 232:
        icon = "389"
      default:
        icon = "113"
    }
    return icon
  }
}
