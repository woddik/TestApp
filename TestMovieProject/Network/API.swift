//
//  API.swift
//  TestMovieProject
//
//  Created by Woddi on 19.01.2021.
//

import Foundation

// MARK: - API

extension NetworkService {
    
    func getPopularMovies(page number: Int,
                          success: @escaping ([DiscoverMovie]) -> Void,
                          failure: ((NetworkError) -> Void)? = nil) {
        let requeest = DiscoverMovieRequest(page: number)
        run(requestable: requeest, success: { (rsponse: ArrayDecodableItem<DiscoverMovie>) in
            success(rsponse.array)
        }, failure: failure)
    }
    
    func searchMovies(page number: Int,
                      query: String,
                      success: @escaping ([DiscoverMovie]) -> Void,
                      failure: ((NetworkError) -> Void)? = nil) {
        let requeest = SearchMovieRequest(page: number, query: query)
        run(requestable: requeest, success: { (rsponse: ArrayDecodableItem<DiscoverMovie>) in
            success(rsponse.array)
        }, failure: failure)
    }
    
    func getMovieDetail(by identifier: Int,
                        success: @escaping (MovieDetail) -> Void,
                        failure: ((NetworkError) -> Void)? = nil) {
        let requeest = MovieDetailRequest(movieIdentifier: identifier)
        run(requestable: requeest, success: success, failure: failure)
    }
}
