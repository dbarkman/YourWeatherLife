//
//  CloudPersistenceController.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/20/22.
//

import CoreData
import OSLog

class CloudPersistenceController {
  
  static let shared = CloudPersistenceController()
  
  static let preview: CloudPersistenceController = {
    let result = CloudPersistenceController(inMemory: true)
    let viewContext = result.container.viewContext
    return result
  }()
  
  private let inMemory: Bool
  
  lazy var container: NSPersistentCloudKitContainer = {
    
    let container = NSPersistentCloudKitContainer(name: "YourWeatherLifeiCloud")
    
    guard let description = container.persistentStoreDescriptions.first else {
      fatalError("Failed to retrieve a persistent store description.")
    }
    
    let storesURL = description.url?.deletingLastPathComponent()
    description.url = storesURL?.appendingPathComponent("cloud.sqlite")
    
    if inMemory {
      description.url = URL(fileURLWithPath: "/dev/null")
    }
    
//    description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
//    description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
    
    if UserDefaults.standard.bool(forKey: "disableiCloudSync") {
      description.cloudKitContainerOptions = nil
    }
    
    container.loadPersistentStores { storeDescription, error in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
    
    container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    container.viewContext.automaticallyMergesChangesFromParent = true
    return container
  }()
  
  init(inMemory: Bool = false) {
    self.inMemory = inMemory
  }
}
