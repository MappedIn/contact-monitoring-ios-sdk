//
//  MiPositionManager.swift
//  Contact Monitoring
//

import CoreLocation
import CoreData
import MappedinVenueFormat

/// The main class used to begin tracking the users position
open class MiPositionManager: NSObject, CLLocationManagerDelegate {
    
    let locationManager: CLLocationManager
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var baseUrl: String? = nil
    
    /// The interval in seconds to send the locations back to the server, defaults to 300
    let serverUpdateInterval: Int32
    
    private(set) var keys: MVFCredentials?
    private(set) var CMKey: String
    
    var device: Device? = nil
    var geofenceManager: GeofenceManager? = nil
    public var delegate: PositionDelegate? = nil
    var venue: Venue? = nil
    
    let context = CoreDataManager.sharedManager.persistentContainer.viewContext
    let client: HttpClient
    
    public init(baseUrl: String? = nil, keys: MVFCredentials? = nil, CMKey: String, serverUpdateInterval: Int32 = 300) {
        self.serverUpdateInterval = serverUpdateInterval
        self.locationManager = CLLocationManager()
        self.keys = keys
        self.CMKey = CMKey
        
        // Obtain the keys from the Info.plist if they are not passed into the init
        if keys == nil {
            if let info = Bundle.main.path(forResource: "Info", ofType: "plist"),
                let data = NSData(contentsOfFile: info),
                let datasourceDictionary = try? PropertyListSerialization.propertyList(from: data as Data, options: [], format: nil) as? Dictionary<String, Any>,
                let keys = datasourceDictionary["MVFCredentials"] as? Dictionary<String, String>,
                let MVFKey = keys["key"],
                let MVFSecret = keys["secret"] {
                self.keys = MVFCredentials(key: MVFKey, secret: MVFSecret)
            } else {
                print("Invalid keys in info.plist")
            }
        } else {
            self.keys = keys
        }
        
        let url = baseUrl ?? ""
        self.client = HttpClient(baseUrl: url)
        self.baseUrl = url
        
        super.init()
                
        locationManager.delegate = self
        geofenceManager = GeofenceManager(positionManager: self)
    }
    
    /// Starts contact monitoring. Checks if hasUserConsent is true first, if not position tracking does not start. If it is true, it will then check if the device is activated and starts tracking if it is activated, otherwise it will activate the device first and then start tracking
    public func startMonitoring() {
        device = getDevice()
        if let _device = device {
            
            if (_device.hasUserConsent == 0 || _device.hasUserConsent == nil) {
                print("User has not consented to contact monitoring")
                return
            }
            
            if (_device.isActivated == 0 || _device.isActivated == nil) {
                activateDevice(device: _device, CMKey: CMKey, onActivated: { status in
                    if status == DeviceStatus.activated {
                        self.getToken(_device)
                    } else {
                        print("Device failed to activate")
                    }
                })
            } else {
                self.getToken(_device)
            }
        }
    }
    
    public func stopMonitoring() {
        locationManager.stopUpdatingLocation()
        delegate?.onTrackingUpdate(trackingStatus: .stopped)
    }
    
    ///Get the stored device from CoreData or create a new one
    /// - Returns: The device instance, if a device isn't found a new one will be generated with a new UUID, and also isActivated and hasUserConsent will be defaulted to false
    public func getDevice() -> Device {
        let deviceRequest = NSFetchRequest<Device>(entityName: "Device")
        deviceRequest.fetchLimit = 1

        do {
            let devices: [Device] = try context.fetch(deviceRequest)
            if let firstDevice = devices.first {
                return firstDevice
            }
        } catch let error as NSError {
            print(error)
        }

        let device = Device(context: context)
        device.id = UUID.init()
        device.type = DeviceUtil().userDeviceName()
        device.isActivated = false
        device.hasUserConsent = false
        
        do {
            try context.save()
        } catch let error as NSError {
            print(error)
        }
        
        return device
    }
    
    /// Sets user consent, position tracking will only be enabled if this is true. The developer should set this to true in a transparent manner to the user
    /// - Parameter userConsent: The boolean value to set the user consent to
    public func setUserConsent(userConsent: Bool) {
        Device.setHasUserConsent(context: context, device: getDevice(), userConsent: userConsent)
    }
    
    /// Activates the device from the server, passes the device id and invite code to activate it
    func activateDevice(device: Device, CMKey: String, onActivated: @escaping (DeviceStatus) -> Void) {
        
        if let deviceType = device.type {
            client.activateDevice(deviceId: device.id, inviteCode: CMKey, deviceType: deviceType, callback: { (data, response, error) in
                guard let urlResponse = response as? HTTPURLResponse else {
                    return
                }
                if error == nil && 200 <= urlResponse.statusCode && urlResponse.statusCode < 300 {

                    let venueResponse = try? JSONDecoder().decode(VenueResponse.self, from: data!)
                    
                    if let venueResponse = venueResponse {
                        device.isActivated = true
                        device.venue = venueResponse.venue
                        
                        do {
                            try self.context.save()
                            onActivated(DeviceStatus.activated)
                            return
                        } catch let error as NSError {
                            print(error)
                        }
                    }

                }
                onActivated(DeviceStatus.inactivated)
            })
        }
    }
    
    ///Gets the venue based off the venue passed in (retrieved from the activating the device) and starts tracking the user
    func getVenue(venueName: String) {
        if self.venue != nil && self.venue!.name == venueName {
            self.startPositionTracking(venue: self.venue!)
            return
        }
        downloadVenue(venueName: venueName, callback: { venue in
            self.venue = venue
            if let _venue = venue {
                self.delegate?.onVenueLoaded(venue: venue)
                self.startPositionTracking(venue: _venue)
            } else {
                print("Error getting venue, tracking not started")
            }
        })
    }
    
    /// Starts position tracking in the venue and initializes geofence monitoring based off of the venue
    func startPositionTracking(venue: Venue) {
        self.initGeofence(venue: venue)
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        
        if (authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse) {
            self.delegate?.onTrackingUpdate(trackingStatus: .started)
        }
    }
    
    /// Initialize geofence monitoring for the venue, based off of the region calculated for the venue
    func initGeofence(venue: Venue) {
        self.venue = venue
        if let region = venue.region {
            geofenceManager?.setUpGeofence(region: region)
        }
    }
    
    /// Gets the token for the device and gets venue if it succeeds
    func getToken(_ device: Device) {
        device.getToken(client: self.client, context: self.context) { tokenStatus, updatedDevice in
            if (tokenStatus == .success) {
                self.getVenue(venueName: device.venue ?? "")
            }
        }
    }
    
    /// Download the venue from the MVFDownloader
    func downloadVenue(venueName: String, callback: @escaping (Venue?) -> Void){
        
        if let keys = self.keys {
        let mvfDownloader = MVFDownloader(key: keys.key, secret: keys.secret)
            mvfDownloader.downloadFiles(venue: venueName, completion: { (result) in
                switch result {
                case .success(let mvfResult):
                    let path = mvfResult.path.absoluteString
                    let polygons = self.getVenuePolygons(path: path)
                    callback(Venue(polygons: polygons, name: venueName))
                case .failure(let error):
                    print(error)
                    callback(nil)
                }
            })
        }
    }
    
    ///Parses out the building.geojson from the MVFDownloader response and returns the coordinates for the venue
    func getVenuePolygons(path: String) -> [[[CLLocationCoordinate2D]]] {
        if let buildingUrl = URL.init(string: path + "/building.geojson"),
            let data = try? Data(contentsOf: buildingUrl),
            let building = try? JSONDecoder().decode(Building.self, from: data) {
            
            var polygons: [[[CLLocationCoordinate2D]]] = []
            for feature in building.features {
                polygons.append(contentsOf: feature.geometry.coordinates.multiPolygon.map {polygon in
                    polygon.map { ring in
                        ring.map { point in
                            CLLocationCoordinate2D(latitude: point[1], longitude: point[0])
                        }
                    }
                })
                
            }
            
            return polygons
            
        }
        print("Failed to find/parse venue")
        return []
    }
    
}
