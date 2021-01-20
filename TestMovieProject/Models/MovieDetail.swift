//
//  MovieDetail.swift
//  TestMovieProject
//
//  Created by Woddi on 20.01.2021.
//

import Foundation

struct MovieDetail: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case releaseDate = "release_date"
        case posterURL = "poster_path"
        case overview
        case title
    }
    
    let releaseDate: Date
    let overview: String
    let title: String
    let posterURL: URL?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        overview = try container.decode(String.self, forKey: .overview)
        releaseDate = try container.decode(Date.self, forKey: .releaseDate)
        
        if let path = try container.decodeIfPresent(String.self, forKey: .posterURL) {
            posterURL = URL(string: NetworkService.Defaults.imageBaseURL + path)
        } else {
            posterURL = nil
        }
    }
}
