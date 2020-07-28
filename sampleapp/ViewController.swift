//
//  ViewController.swift
//  Contact Monitoring
//

import UIKit
import CoreLocation
import MapKit
import MappedinCM

class ViewController: UIViewController, MKMapViewDelegate, PositionDelegate {

    @IBOutlet var map: MKMapView!
    @IBOutlet weak var logLabel: UILabel!
    @IBOutlet weak var trackingLabel: UILabel!
    
    var positionManager = MiPositionManager(baseUrl: "ENTER SERVER URL HERE", CMKey: "ENTER CM KEY HERE")
    
    override func viewDidLoad() {
        map.delegate = self
        super.viewDidLoad()
        
        positionManager.delegate = self
        positionManager.setUserConsent(userConsent: true) //Only needs to be called once
        positionManager.startMonitoring()

    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: overlay)
            circleRenderer.fillColor = UIColor.blue
            circleRenderer.alpha = 0.2
            return circleRenderer
        } else if overlay is MKPolygon {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.strokeColor = UIColor.magenta
            polygonView.lineWidth = 2.0
            return polygonView
        }
        return MKOverlayRenderer()
    }
    
    func mapView(mapView: MKMapView!, viewForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        return MKPolygonRenderer(overlay: overlay)
    }
    
    func onLocationUpdate(location: CLLocation, positionStatus: PositionStatus) {
        
        switch(positionStatus) {
            
        case .inside:
            logLabel.text = "Inside the venue " + String(format: "%.3f", location.horizontalAccuracy) + "m"
        case .outside:
            logLabel.text = "Outside the venue " + String(format: "%.3f", location.horizontalAccuracy) + "m"
        }
        
    }
    
    func onTrackingUpdate(trackingStatus: TrackingStatus) {
        DispatchQueue.main.async {
            switch (trackingStatus) {
            case .started:
                self.trackingLabel.text = "Started tracking"
                
            case .stopped:
                self.trackingLabel.text = "Stopped Tracking"
            }
        }
    }

    func onVenueLoaded(venue: Venue?) {
        DispatchQueue.main.async {
            if let _venue = venue {
                let circle = MKCircle(center: _venue.region!.center, radius: _venue.region!.radius)
                var polygons: [MKPolygon] = []
                for polygon in venue?.polygons ?? [] {
                    let innerPolygons = polygon[1...].map { innerPolygon in
                        MKPolygon(coordinates: innerPolygon, count: innerPolygon.count)
                    }
                    polygons.append(MKPolygon(coordinates: polygon[0], count: polygon[0].count, interiorPolygons: innerPolygons))
                }
                self.map.addOverlay(circle)
                self.map.addOverlays(polygons)
                self.map.visibleMapRect = circle.boundingMapRect
            }
        }
    }
}

