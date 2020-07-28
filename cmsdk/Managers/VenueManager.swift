//
//  PolygonManager.swift
//  position_tracking
//

import CoreLocation

/// Handles the geometry calculations for checking if a coordinate is in the venue and for creating the geofence region circle using a minimum bounding circle algorithm
/// Reference: https://www.nayuki.io/page/smallest-enclosing-circle
internal class VenueManager {
    
    let venue: Venue
    
    init(venue: Venue) {
        self.venue = venue
    }
    
    ///Checks if the passed in coordinate is in the venue
    /// - Parameter coordinate: The coordinate to check if it is in the venue
    /// - Returns: Bool, whether or not the coordinate is in the venue
    internal func isInVenue(coordinate: CLLocationCoordinate2D) -> Bool {
        var isInVenue = false
        
        for polygon in venue.polygons {
            let _outerPolygon = polygon.first
            guard let outerPolygon = _outerPolygon else {
                continue
            }
            for i in 0 ..< outerPolygon.count {
                let vertex = outerPolygon[i]
                let nextVertex = outerPolygon[(i+1) % outerPolygon.count]
            
                let v1x = vertex.longitude
                let v1y = vertex.latitude
                let v2x = nextVertex.longitude
                let v2y = nextVertex.latitude
            
                if ((v1y <= coordinate.latitude) && (v2y > coordinate.latitude) ||
                    (v2y <= coordinate.latitude) && (v1y > coordinate.latitude)) {
                    let intersection = (v2x - v1x) * (coordinate.latitude - v1y) / (v2y - v1y) + v1x
                    
                    if intersection < coordinate.longitude {
                        isInVenue = !isInVenue
                    }
                }
            }
            
            if isInVenue {
                return true
            }
        }
        
        return false
    }
    
    /// Creates a CLCircularRegion that represents the minimum bounding circle from the passed in array of coordinates
    /// - Parameter points:  An array of points to create the minimum bounding circle
    /// - Returns: CLCircularRegion, the minimum bounding circle
    internal func makeCircle(points: [CLLocationCoordinate2D]) -> CLCircularRegion? {
        let shuffled = points.shuffled()
        
        var circle: CLCircularRegion? = nil
        for (i, point) in shuffled.enumerated() {
            if circle == nil || !isInCircle(circle: circle, point: point) {
                circle = makeCircleOnePoint(points: Array(shuffled.prefix(upTo: i + 1)), point: point)
            }
        }
        return circle
    }

    private func makeCircleOnePoint(points: [CLLocationCoordinate2D], point: CLLocationCoordinate2D) -> CLCircularRegion? {
        var circle: CLCircularRegion? = CLCircularRegion(center: point, radius: 0, identifier: "")
        for (i, point2) in points.enumerated() {
            if !isInCircle(circle: circle, point: point2) {
                if circle?.radius == 0 {
                    circle = makeDiameter(point: point, point: point2)
                } else {
                    circle = makeCircleTwoPoints(points: Array(points.prefix(upTo: i+1)), point: point, point: point2)
                }
            }
        }
        return circle
    }

    private func makeCircleTwoPoints(points: [CLLocationCoordinate2D], point point1: CLLocationCoordinate2D, point point2: CLLocationCoordinate2D) -> CLCircularRegion? {
        let circle: CLCircularRegion? = makeDiameter(point: point1, point: point2)
        var left: CLCircularRegion? = nil
        var right: CLCircularRegion? = nil
        let p1Lon = point1.longitude
        let p1Lat = point1.latitude
        let p2Lon = point2.longitude
        let p2Lat = point2.latitude
        
        for point in points {
            if isInCircle(circle: circle, point: point) {
                continue
            }
            let cross = crossProduct(p1Lon, p1Lat, p2Lon, p2Lat, point.longitude, point.latitude)
            let currCircle = makeCircumcircle(point: point1, point: point2, point: point)
            if currCircle == nil {
                continue
            }
            
            let circleCross = crossProduct(p1Lon, p1Lat, p2Lon, p2Lat, currCircle!.center.longitude, currCircle!.center.latitude)
            if cross > 0 && (left == nil || circleCross > crossProduct(p1Lon, p1Lat, p2Lon, p2Lat, left!.center.longitude, left!.center.latitude)) {
                left = currCircle
            } else if cross < 0 && (right == nil || circleCross < crossProduct(p1Lon, p1Lat, p2Lon, p2Lat, right!.center.longitude, right!.center.latitude)) {
                right = currCircle
            }
        }
        
        if left == nil && right == nil {
            return circle
        } else if left == nil {
            return right
        } else if right == nil {
            return left
        } else {
            return Double(left!.radius) < Double(right!.radius) ? left : right
        }
    }

    private func makeDiameter(point point1: CLLocationCoordinate2D, point point2: CLLocationCoordinate2D) -> CLCircularRegion {
        let centerLon = (point1.longitude + point2.longitude)/2
        let centerLat = (point1.latitude + point2.latitude)/2
        let center = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon)
        let radius1 = sqrt(pow(centerLon - point1.longitude, 2) + pow(centerLat - point1.latitude, 2))
        let radius2 = sqrt(pow(centerLon - point2.longitude, 2) + pow(centerLat - point2.latitude, 2))
        let circle = CLCircularRegion(center: center, radius: max(radius1, radius2), identifier: "")
        return circle
    }

    private func makeCircumcircle(point point1: CLLocationCoordinate2D, point point2: CLLocationCoordinate2D, point point3: CLLocationCoordinate2D) -> CLCircularRegion? {
        let oLon = (min(point1.longitude, point2.longitude, point3.longitude) + max(point1.longitude, point2.longitude, point3.longitude)) / 2
        let oLat = (min(point1.latitude, point2.latitude, point3.latitude) + max(point1.latitude, point2.latitude, point3.latitude)) / 2
        let p1x = point1.longitude - oLon; let p1y = point1.latitude - oLat
        let p2x = point2.longitude - oLon; let p2y = point2.latitude - oLat
        let p3x = point3.longitude - oLon; let p3y = point3.latitude - oLat
        let d = (p1x * (p2y - p3y) +
                        p2x * (p3y - p1y) +
                        p3x * (p1y - p2y)) * 2
        if d == 0 {
            return nil
        }
        let centerLon = oLon + ((p1x*p1x + p1y*p1y) * (p2y - p3y) + (p2x*p2x + p2y*p2y) * (p3y - p1y) + (p3x*p3x + p3y*p3y) * (p1y - p2y)) / d
        let centerLat = oLat + ((p1x*p1x + p1y*p1y) * (p3x - p2x) + (p2x*p2x + p2y*p2y) * (p1x - p3x) + (p3x*p3x + p3y*p3y) * (p2x - p1x)) / d
        let center = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon)
        let radius1 = sqrt(pow(centerLon - point1.longitude, 2) + pow(centerLat - point1.latitude, 2))
        let radius2 = sqrt(pow(centerLon - point2.longitude, 2) + pow(centerLat - point2.latitude, 2))
        let radius3 = sqrt(pow(centerLon - point3.longitude, 2) + pow(centerLat - point3.latitude, 2))
        let circle = CLCircularRegion(center: center, radius: max(radius1, radius2, radius3), identifier: "")
        return circle
    }

    private func isInCircle(circle: CLCircularRegion?, point: CLLocationCoordinate2D, multEpsilon: Double = 1 + pow(10, -14)) -> Bool {
        return circle != nil && sqrt(pow(point.longitude - circle!.center.longitude, 2) + pow(point.latitude - circle!.center.latitude, 2)) <= circle!.radius * multEpsilon
    }

    private func crossProduct(_ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double) -> Double {
        return (x1 - x0) * (y2 - y0) - (y1 - y0) * (x2 - x0)
    }
    
}
