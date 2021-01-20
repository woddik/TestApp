//
//  DiscoverMovie+CD.swift
//  TestMovieProject
//
//  Created by Woddi on 20.01.2021.
//

import Foundation

// MARK: -

extension DiscoverMovie {
    
    func toCoreDataItem() -> CDMovie? {
        guard CDMovie.findFirst(by: NSPredicate(format: "id == %i", identifier)) == nil else {
            return nil
        }
        let movie = CDMovie.create()
        movie?.title = title
        movie?.poster_path = "/" + (posterURL?.lastPathComponent ?? "")
        movie?.id = Int64(identifier)

        return movie
    }
}
