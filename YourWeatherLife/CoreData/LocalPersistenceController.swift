//
//  LocalPersistenceController.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/19/22.
//

import CoreData
import OSLog

class LocalPersistenceController {
  
  static let shared = LocalPersistenceController()
  
  private let inMemory: Bool
  
  lazy var container: NSPersistentContainer = {
    
    let container = NSPersistentContainer(name: "YourWeatherLife")
    
    guard let description = container.persistentStoreDescriptions.first else {
      fatalError("Failed to retrieve a persistent store description.")
    }
    
    let storesURL = description.url?.deletingLastPathComponent()
    description.url = storesURL?.appendingPathComponent("local.sqlite")
    
    if inMemory {
      description.url = URL(fileURLWithPath: "/dev/null")
    }
    
    container.loadPersistentStores { storeDescription, error in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
    
    container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    return container
  }()
  
  init(inMemory: Bool = false) {
    self.inMemory = inMemory
  }
}
