//
//  DiscoverMovieRequest.swift
//  TestMovieProject
//
//  Created by Woddi on 18.01.2021.
//

import Foundation

struct DiscoverMovieRequest: Requstable {
    
    let path: String = "discover/movie"
    
    let page: Int
    
    var parameters: Parameters? {
        return Parameters(page: page)
    }
}
