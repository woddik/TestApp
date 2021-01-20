//
//  SearchMovieRequest.swift
//  TestMovieProject
//
//  Created by Woddi on 19.01.2021.
//

import Foundation

struct SearchMovieRequest: Requstable {
    
    let path: String = "search/movie"

    let page: Int
    
    let query: String
    
    var parameters: Parameters? {
        return Parameters(dict: ["query": query], page: page)
    }

}
