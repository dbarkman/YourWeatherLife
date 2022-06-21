//
//  LocalPersistenceController.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/19/22.
//

import CoreData
import OSLog

class LocalPersistenceController {
  
  let logger = Logger(subsystem: "com.dbarkman.YourWeatherLife", category: "LocalPersistenceController")

  static let shared = LocalPersistenceController()
  
  static let preview: LocalPersistenceController = {
    let result = LocalPersistenceController(inMemory: true)
    let viewContext = result.container.viewContext
//    for _ in 0..<10 {
//      let newItem = Item(context: viewContext)
//      newItem.timestamp = Date()
//    }
//    do {
//      try viewContext.save()
//    } catch {
//      let nsError = error as NSError
//      fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//    }
    return result
  }()
  
  private let inMemory: Bool
  
  lazy var container: NSPersistentContainer = {
    
    let container = NSPersistentContainer(name: "YourWeatherLife")
    
    guard let description = container.persistentStoreDescriptions.first else {
      fatalError("Failed to retrieve a persistent store description.")
    }
    logger.debug("Retrieved a persistent store description! 🎉")
    
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
