//
//  HttpClient.swift
//  position_tracking
//

import CoreData

class HttpClient {
    
    let baseUrl: String
    
    init(baseUrl: String) {
        self.baseUrl = baseUrl
    }
    
    open func sendLocation(locations: [Location], device: Device, context: NSManagedObjectContext, callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var parameters: [[String: Any]] = []
        
        locations.forEach { location in
            
            let parameter: [String: Any] = [
                "device": location.deviceId,
                "acc": location.accuracy,
                "lonlat": [location.longitude, location.latitude],
                "time": (location.createdAt.timeIntervalSince1970 * 1000).rounded(),
                "venue": location.venueId,
                "floor": location.floor,
                "userConsent": true,
            ]
            parameters.append(parameter)
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            let url = URL(string: self.baseUrl + "/positions")!
            device.getToken(client: self, context: context) {tokenStatus, _device in
                if (tokenStatus == .success && _device != nil) {
                    self.postRequest(url: url, data: data, authHeader: "Bearer " + (_device!.authToken ?? ""), callback: callback)
                }
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func postRequest(url: URL, data: Data, authHeader: String? = nil, callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data

        if let authHeader = authHeader {
            request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            callback(data, response, error)
        }
        task.resume()
    }
    
    private func getRequest(url: URL, authHeader: String? = nil, callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let authHeader = authHeader {
            request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            callback(data, response, error)
        }
        task.resume()
    }
    
    func activateDevice(deviceId: UUID, inviteCode: String, deviceType: String, callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let parameter: [String: Any] = [
            "code": inviteCode,
            "deviceType": deviceType
        ]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: parameter, options: .prettyPrinted)
            let url = URL(string: self.baseUrl + "/device/\(deviceId)/activate")!
            postRequest(url: url, data: data, callback: callback)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func getToken(deviceId: String, callback: @escaping (Token?) -> Void) {
        let url = URL(string: self.baseUrl + "/device/\(deviceId)/token")!
        getRequest(url: url, callback: { (data, response, error) in
            if let _data = data {
                let token = try? JSONDecoder().decode(Token.self, from: _data)
                callback(token)
            } else {
                callback(nil)
            }
        })
    }
    
}
