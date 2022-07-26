//
//  CloudKitManager.swift
//  YourWeatherLife
//
//  Created by David Barkman on 7/17/22.
//

import CloudKit
import OSLog

class CloudKitManager {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "CloudKitManager")
  
  static let shared = CloudKitManager()

  private let container = CKContainer(identifier: "iCloud.com.dbarkman.YourWeatherLife")
  private(set) var accountStatus: CKAccountStatus = .couldNotDetermine
  
  private init() {
    Task {
      await requestAccountStatus()
    }
    setupNotificationHandling()
  }
  
  func requestAccountStatus() async -> CKAccountStatus {
    do {
      self.accountStatus = try await container.accountStatus()
      return self.accountStatus
    } catch {
      logger.error("Error: \(error.localizedDescription)")
      return .couldNotDetermine
    }
  }
  
  fileprivate func setupNotificationHandling() {
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(self, selector: #selector(accountDidChange(_:)), name: Notification.Name.CKAccountChanged, object: nil)
  }
  
  @objc private func accountDidChange(_ notification: Notification) {
    awaitRequestAccountStatus()
  }
  private func awaitRequestAccountStatus() {
    Task {
      await _ = requestAccountStatus()
      if accountStatus != .available {
        UserDefaults.standard.set(true, forKey: "userNotLoggedIniCloud")
      }
    }
  }
}
