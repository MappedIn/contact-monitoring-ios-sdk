//
//  Token.swift
//  position_tracking
//

/// JWT Token obtained from the server, contains the authorization token and an expiresAt date
struct Token: Codable {
    let token: String
    let expiresAt: String
}
