//
//  CoreDataManager.swift
//

import CoreData
import UIKit

internal class CoreDataManager {
  
  static let sharedManager = CoreDataManager()
  let identifier: String  = "com.mappedin.cmsdk"
  let model: String = "LocationData"
  private init() {}
  
  lazy var persistentContainer: NSPersistentContainer = {

          let messageKitBundle = Bundle(identifier: self.identifier)
          let modelURL = messageKitBundle!.url(forResource: self.model, withExtension: "momd")!
          let managedObjectModel =  NSManagedObjectModel(contentsOf: modelURL)
          
          let container = NSPersistentContainer(name: self.model, managedObjectModel: managedObjectModel!)
          container.loadPersistentStores { (storeDescription, error) in
              
              if let err = error{
                  fatalError("❌ Loading of store failed:\(err)")
              }
          }
          
          return container
      }()
  
  func saveContext () {
    let context = CoreDataManager.sharedManager.persistentContainer.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        print(error)
      }
    }
  }
}
