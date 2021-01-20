//
//  HttpMethod.swift
//  TestMovieProject
//
//  Created by Woddi on 18.01.2021.
//

import Foundation

enum HttpMethod: String {
    case options = "OPTIONS"
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case trace = "TRACE"
    case connect = "CONNECT"
    
    var isURLConvertible: Bool {
        return self == .get
    }
}
