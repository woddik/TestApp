//
//  DateFormatter+Utils.swift
//  TestMovieProject
//
//  Created by Woddi on 20.01.2021.
//

import Foundation

extension DateFormatter {
    
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static let publicDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y"
        return formatter
    }()
}
