//
//  MovieDetailRequest.swift
//  TestMovieProject
//
//  Created by Woddi on 20.01.2021.
//

import Foundation

struct MovieDetailRequest: Requstable {
    
    var path: String {
        return "movie/\(movieIdentifier)"
    }

    let movieIdentifier: Int
}
