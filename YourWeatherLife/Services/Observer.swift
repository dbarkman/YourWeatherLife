//
//  Observer.swift
//  YourWeatherLife
//
//  Created by David Barkman on 7/3/22.
//

import UIKit

class Observer: ObservableObject {
  
  @Published var enteredForeground = true
  
  init() {
    if #available(iOS 13.0, *) {
      NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIScene.willEnterForegroundNotification, object: nil)
    } else {
      NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
  }
  
  @objc private func willEnterForeground() {
    enteredForeground.toggle()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}
