//
//  Device.swift
//  position_tracking
//

import Foundation
import CoreData

extension Device {    
    
    /// Checks for a valid token against the expiresAt date and obtains a new token if expired otherwise returns the currentToken
    func getToken(client: HttpClient, context: NSManagedObjectContext, callback: @escaping (TokenStatus, Device?) -> Void) {
        if let expiresAt = self.expiresAt {
            if Int(expiresAt.timeIntervalSinceNow) < 0 {
                retrieveToken(client, context, callback)
            } else {
                return callback(TokenStatus.success, self)
            }
        }
        
        retrieveToken(client, context, callback)
    }
    
    /// Retrieves a new token from the server and stores it if successful
    private func retrieveToken(_ client: HttpClient, _ context: NSManagedObjectContext, _ callback: @escaping (TokenStatus, Device?) -> Void) {
        client.getToken(deviceId: self.id.uuidString, callback: { token in
            if token == nil {
                print("Failed to get token")
                return callback(TokenStatus.failure, nil)
            } else {
                self.authToken = token!.token
                self.expiresAt = token!.expiresAt.toDate()
                do {
                    try context.save()
                    return callback(TokenStatus.success, self)
                } catch {
                    print("Failed to save to device")
                    return callback(TokenStatus.failure, nil)
                }
            }
        })
    }
}
