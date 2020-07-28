//
//  VenueResponse.swift
//  position_tracking
//

///The response from activating the device, provides a venue slug that is used by MVFDownloader to obtain the geometry of the venue
struct VenueResponse: Codable {
    let venue: String
}
