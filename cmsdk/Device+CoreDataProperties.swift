//
//  Device+CoreDataProperties.swift
//  position_tracking
//

import Foundation
import CoreData


extension Device {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Device> {
        return NSFetchRequest<Device>(entityName: "Device")
    }

    @NSManaged public var authToken: String?
    @NSManaged public var expiresAt: Date?
    @NSManaged public var id: UUID
    @NSManaged public var isActivated: NSNumber?
    @NSManaged public var hasUserConsent: NSNumber?
    @NSManaged public var type: String?
    @NSManaged public var venue: String?
    
    public class func setHasUserConsent(context: NSManagedObjectContext, device: Device, userConsent: Bool) {
        
        device.hasUserConsent = userConsent ? 1 : 0
        
        do {
            try context.save()
        } catch let error {
            print(error)
        }
    }
}
