//
//  HTTPStatusCode.swift
//  TestMovieProject
//
//  Created by Woddi on 18.01.2021.
//

import Foundation

enum HTTPStatusCode: Int {
    case processing = 102
    case success = 200
    case handleRestorePassword = 204
    case redirection = 300
    case badRequest = 400
    case unAuthorized = 401
    case paymentRequired = 402
    case forbidden = 403
    case notFound = 404
    case internalServerError = 500
    case notImplemented = 501
    case badGateway = 502
    case serviceUnavailable = 503
    case `none` = 666
    
    init(rawValue: Int) {
        switch rawValue {
        case 100..<200: self = .processing
        case 200..<300: self = .success
        case 300..<400: self = .redirection
        case 400: self = .badRequest
        case 401: self = .unAuthorized
        case 402: self = .paymentRequired
        case 403: self = .forbidden
        case 404: self = .notFound
        case 500: self = .internalServerError
        case 501: self = .notImplemented
        case 502: self = .badGateway
        case 503: self = .serviceUnavailable
        default: self = .none
        }
    }
    
    var isServerError: Bool {
        switch rawValue {
        case 500..<600: return true
        default: return false
        }
    }
}
