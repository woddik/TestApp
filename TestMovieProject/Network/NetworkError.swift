//
//  NetworkError.swift
//  TestMovieProject
//
//  Created by Woddi on 18.01.2021.
//

import Foundation

struct NetworkError: Error {
    
    let code: HTTPStatusCode
    
    let description: String

}

// MARK: - Initializer

extension NetworkError {
    
    init(error: Error) {
        let err = error as NSError
        code = HTTPStatusCode(rawValue: err.code)
        description = err.localizedDescription
    }
}

// MARK: - Public methods

extension NetworkError {
    
    static var badRequest: NetworkError {
        return NetworkError(code: .badRequest, description: "Bad Request: \(#file) -> \(#line)")
    }
}
