//
//  Location+CoreDataProperties.swift
//  position_tracking
//

import Foundation
import CoreData
import CoreLocation

extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double
    @NSManaged public var accuracy: Double
    @NSManaged public var floor: Int32
    @NSManaged public var deviceId: String
    @NSManaged public var venueId: String
    @NSManaged public var createdAt: Date
    @NSManaged public var uploadStatus: Int16
    
    public enum UploadStatus: Int16 {
        case notSent = 0, sent
    }
    

    @nonobjc public class func create(location: CLLocation, deviceId: String, venueId: String, context: NSManagedObjectContext) {
          let locationObject = Location(context: context)
          
          locationObject.longitude = location.coordinate.longitude
          locationObject.latitude = location.coordinate.latitude
          locationObject.accuracy = location.horizontalAccuracy
          locationObject.floor = Int32(location.floor?.level ?? 0)
          locationObject.deviceId = deviceId
          locationObject.venueId = venueId
          locationObject.uploadStatus = 0
          locationObject.createdAt = Date()
          
          do {
              try context.save()
          } catch let error as NSError {
              print(error)
          }
      }
      
      public class func getFirst(context: NSManagedObjectContext) -> Location? {
          let locationRequest = NSFetchRequest<Location>(entityName: "Location")
          locationRequest.fetchLimit = 1
          locationRequest.predicate = NSPredicate(format: "uploadStatus == \(UploadStatus.notSent.rawValue)")
          locationRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
          do {
              let locations: [Location] = try context.fetch(locationRequest)
              if let firstLocation = locations.first {
                  return firstLocation
              }
          } catch let error as NSError {
              print(error)
          }
          return nil
      }
      
      public class func getAll(context: NSManagedObjectContext) -> [Location] {
          let locationRequest = NSFetchRequest<Location>(entityName: "Location")

          do {
              let locations: [Location] = try context.fetch(locationRequest)
              return locations
          } catch let error as NSError {
              print(error)
          }
          return []
      }
    
    public class func getAllByStatus(context: NSManagedObjectContext, uploadStatus: UploadStatus) -> [Location] {
        let locationRequest = NSFetchRequest<Location>(entityName: "Location")
        locationRequest.predicate = NSPredicate(format: "uploadStatus == \(uploadStatus.rawValue)")

        do {
            let locations: [Location] = try context.fetch(locationRequest)
            return locations
        } catch let error as NSError {
            print(error)
        }
        return []
    }
      
      public class func deleteAll(context: NSManagedObjectContext) {
          let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
          fetchRequest.returnsObjectsAsFaults = false
          do {
              let results = try context.fetch(fetchRequest)
              for object in results {
                  guard let objectData = object as? NSManagedObject else {continue}
                  context.delete(objectData)
              }
          } catch let error {
              print(error)
          }
      }
    
    public class func deleteLocations(context: NSManagedObjectContext, locations: [Location]) {
        for location in locations {
            context.delete(location)
        }
        do {
            try context.save()
        } catch let error {
            print(error)
        }
    }
    
    public class func setUploadStatus(context: NSManagedObjectContext, locations: [Location], uploadStatus: UploadStatus) {
        for location in locations {
            location.uploadStatus = uploadStatus.rawValue
        }
        do {
            try context.save()
        } catch let error {
            print(error)
        }
    }
}
