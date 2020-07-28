//
//  MiPositionManager.swift
//  position_tracking
//

import CoreData
import CoreLocation

extension MiPositionManager {
    
    /// Handles if the authorization has changed to start or stop updating location
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorizationStatus = status
        delegate?.onAuthorizationUpdate(authorizationStatus: status)
        
        if (status == .authorizedAlways || status == .authorizedWhenInUse) {
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.startUpdatingLocation()
        } else {
            locationManager.stopUpdatingLocation()
        }
    }

    /// Handles when a new location has been detected
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last, let _venue = venue {
            
            /// Checks if the coordinate is in the geofence, if not stop tracking
            if (!_venue.isInGeofence(coordinate: location.coordinate)) {
                stopMonitoring()
            }
            
            /// Checks if the coordinate is in the venue, if not do not store the location
            if (!_venue.isInVenue(coordinate: location.coordinate)) {
                delegate?.onLocationUpdate(location: location, positionStatus: PositionStatus.outside)
                return
            }
            
            delegate?.onLocationUpdate(location: location, positionStatus: PositionStatus.inside)
            
            /// Create a new Location and store it in CoreData
            Location.create(location: location, deviceId: device?.id.uuidString ?? "", venueId: venue?.name ?? "", context: context)
            
            let firstLocation = Location.getFirst(context: context)
            if let _firstLocation = firstLocation {
                
                /// Check the last location, if it is older than the serverUpdateInterval make a request to send all the locations to the server
                if (Int(_firstLocation.createdAt.timeIntervalSinceNow * -1) > serverUpdateInterval) {

                    guard let device = device else {
                        return
                    }
                    
                    let locations = Location.getAllByStatus(context: context, uploadStatus: .notSent)
                    
                    ///Throttle the number of locations sent to the server to 500
                    let throttleCount = 500
                    let throttledLocations = locations.chunked(into: throttleCount)
                    
                    ///Send all the locations in chunks determined by the throttleCount to the server and delete the stored locations from the device
                    for requestLocations in throttledLocations {
                        
                        Location.setUploadStatus(context: context, locations: requestLocations, uploadStatus: .sent)
                        
                        client.sendLocation(locations: requestLocations, device: device, context: context) { (data, response, error) in
                            guard let response = response as? HTTPURLResponse else {
                                return
                            }
                            if 200...300 ~= response.statusCode && error == nil {
                                print("Successfully sent locations to server")
                                Location.deleteLocations(context: self.context, locations: requestLocations)
                            } else {
                               print("Failed to send locations to server")
                               Location.setUploadStatus(context: self.context, locations: requestLocations, uploadStatus: .notSent)
                            }
                        }
                    }
                }
            }
        }
    }
    
    ///Handles when the user enters the geofence region
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        geofenceManager?.handleRegionEvent(region: region, regionStatus: .entered)
    }
            
    ///Handles when the user exits the geofence region
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        geofenceManager?.handleRegionEvent(region: region, regionStatus: .exited)
    }
}
