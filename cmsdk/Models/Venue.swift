//
//  Venue.swift
//  Contact Monitoring
//

import CoreLocation
import MapKit
import MappedinVenueFormat

/// Stores venue information decoded from the MVF data for the venue
open class Venue {

    /// Venue slug
    let name: String
    var venueManager: VenueManager? = nil
    ///The polygons of the venue
    public let polygons: [[[CLLocationCoordinate2D]]]
    /// Geofence region of the venue, calculated using a minimum bounding circle algorithm with a minimum of 200m
    public var region: CLCircularRegion? = nil
    /// Same as region but padded with 100m, used to detect if the user is actually in the region due to issues with geofence region starting before the user is actually in the region
    public var paddedRegion: CLCircularRegion? = nil
    
    public init(polygons: [[[CLLocationCoordinate2D]]], name: String) {
        self.polygons = polygons
        self.name = name
        self.venueManager = VenueManager(venue: self)

        let circle = venueManager?.makeCircle(points: polygons.flatMap({ $0 }).flatMap({ $0 }))
        
        if let _circle = circle {
            let circleRadius = max(_circle.radius * 1000 * 100 + 50, 200)
            region = CLCircularRegion(center: _circle.center, radius: circleRadius, identifier: name)
            paddedRegion = CLCircularRegion(center: _circle.center, radius: circleRadius + 100, identifier: "paddedRegion")
        }
    }
    
    ///Checks if the passed in coordinate is in the venue
    /// - Parameter coordinate: The coordinate to check if it is in the venue
    /// - Returns: Bool, whether or not the coordinate is in the venue
    func isInVenue(coordinate: CLLocationCoordinate2D) -> Bool {
        return venueManager?.isInVenue(coordinate: coordinate) ?? false
    }
    
    /// Checks if the passed in coordinate is in the padded region
    /// - Parameter coordinate: The coordinate to check if it is in the padded geofence region
    /// - Returns: Bool, whether or not the coordinate is in the padded geofence region
    func isInGeofence(coordinate: CLLocationCoordinate2D) -> Bool {
        if let _region = paddedRegion {
            return _region.contains(coordinate)
        }
        
        return false
    }
}
