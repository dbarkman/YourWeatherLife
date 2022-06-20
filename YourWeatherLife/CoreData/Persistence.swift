//
//  Persistence.swift
//  YourWeatherLife
//
//  Created by David Barkman on 6/19/22.
//

import CoreData

class PersistenceController {
  static let shared = PersistenceController()
  
  static let preview: PersistenceController = {
    let result = PersistenceController(inMemory: true)
    let viewContext = result.container.viewContext
    for _ in 0..<10 {
      let newItem = Item(context: viewContext)
      newItem.timestamp = Date()
    }
    do {
      try viewContext.save()
    } catch {
      let nsError = error as NSError
      fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
    return result
  }()
  
  private let inMemory: Bool
  
  lazy var container: NSPersistentCloudKitContainer = {
    
    let container = NSPersistentCloudKitContainer(name: "YourWeatherLife")
    
    guard let description = container.persistentStoreDescriptions.first else {
      fatalError("Failed to retrieve a persistent store description.")
    }
    
    let storesURL = description.url?.deletingLastPathComponent()
    description.url = storesURL?.appendingPathComponent("private.sqlite")
    
    if inMemory {
      description.url = URL(fileURLWithPath: "/dev/null")
    }
    
    container.loadPersistentStores { storeDescription, error in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
    
    container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    container.viewContext.automaticallyMergesChangesFromParent = true
    return container
  }()
  
  init(inMemory: Bool = false) {
    self.inMemory = inMemory
  }
}
