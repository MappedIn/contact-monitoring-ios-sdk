//
//  PositionDelegate.swift
//  Contact Monitoring
//

import CoreLocation

/// PositionDelegate, set the delegate on your [MiPositionManager] instance to receive updates on authorization, location, tracking and when the venue is loaded
public protocol PositionDelegate {
    func onAuthorizationUpdate(authorizationStatus: CLAuthorizationStatus)
    func onLocationUpdate(location: CLLocation, positionStatus: PositionStatus)
    func onTrackingUpdate(trackingStatus: TrackingStatus)
    func onVenueLoaded(venue: Venue?)
}

public extension PositionDelegate {
    func onAuthorizationUpdate(authorizationStatus: CLAuthorizationStatus) {
        
    }
    
    func onLocationUpdate(location: CLLocation, positionStatus: PositionStatus) {
        
    }
    
    func onTrackingUpdate(trackingStatus: TrackingStatus) {
        
    }
    
    func onVenueLoaded(venue: Venue?) {
        
    }
}
