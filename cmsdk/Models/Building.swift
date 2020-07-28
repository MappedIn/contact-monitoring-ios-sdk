//
//  Building.swift
//  position_tracking
//

import CoreLocation

/// Decoded Building from the building.geojson of the MVF response
struct Building: Decodable {
    let type: String
    let features: [Feature]
    
    struct Feature: Decodable {
        let type: String
        let geometry: Geometry
        
        struct Geometry: Decodable {
            let type: String
            let coordinates: Coordinates
            
            struct Coordinates: Decodable {
                var multiPolygon: [[[[Double]]]] = []
                
                init(from decoder: Decoder) throws {
                    if let polygon = try? decoder.singleValueContainer().decode([[[Double]]].self) {
                        self.multiPolygon.append(polygon)
                    }
                    if let multiPolygon = try? decoder.singleValueContainer().decode([[[[Double]]]].self) {
                        self.multiPolygon = multiPolygon
                    }
                }
            }
        }
        
        let properties: Properties
        
        struct Properties: Decodable {
            let id: String
            let venue: String
            let name: String
        }

    }
}
