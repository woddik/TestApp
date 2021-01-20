//
//  ListSource.swift
//  TestMovieProject
//
//  Created by Woddi on 19.01.2021.
//

import Foundation

// MARK: - ListSource

protocol ListSource: AnyObject {
    
    func numberOfSections() -> Int
    
    func numberOfItems(in section: Int) -> Int
    
}
