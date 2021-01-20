//
//  DiscoverMovie.swift
//  TestMovieProject
//
//  Created by Woddi on 18.01.2021.
//

import Foundation

struct DiscoverMovie: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case title
        case posterURL = "poster_path"
        case identifier = "id"
    }
    
    let identifier: Int
    
    let title: String
    
    let posterURL: URL?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        identifier = try container.decode(Int.self, forKey: .identifier)
        
        if let path = try container.decodeIfPresent(String.self, forKey: .posterURL) {
            posterURL = URL(string: NetworkService.Defaults.imageBaseURL + path)
        } else {
            posterURL = nil
        }
    }
}
