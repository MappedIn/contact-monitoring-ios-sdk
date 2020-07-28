//
//  GeofenceManager.swift
//  Contact Monitoring
//

import CoreLocation

///Handles setting up the geofence and handling region events
internal class GeofenceManager {
    
    enum RegionStatus {
        case entered
        case exited
    }
    
    let positionManager: MiPositionManager
    var region: CLCircularRegion? = nil
    
    init (positionManager: MiPositionManager) {
        self.positionManager = positionManager
    }
    
    func setUpGeofence(region: CLCircularRegion) {
        self.region = region
        positionManager.locationManager.requestAlwaysAuthorization()
        
        region.notifyOnExit = true
        region.notifyOnEntry = true
        positionManager.locationManager.startMonitoring(for: region)
    }
    
    func handleRegionEvent(region: CLRegion, regionStatus: RegionStatus) {
        if region is CLCircularRegion {
            switch (regionStatus) {
                case .entered:
                    if let _venue = positionManager.venue {
                        positionManager.startPositionTracking(venue: _venue)
                    }
                case .exited:
                    positionManager.stopMonitoring()
            }
        }
    }
}
