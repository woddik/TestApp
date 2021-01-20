//
//  UITableView+Utils.swift
//  TestMovieProject
//
//  Created by Woddi on 19.01.2021.
//

import UIKit

extension UITableView {
    
    /// Nib name and reuseIdentifier must be equal to the class name
    ///
    /// - Parameter cellClass: any class that inherit from UITableViewCell
    func registerCell(_ cellClass: UITableViewCell.Type) {
        register(UINib(nibName: "\(cellClass)", bundle: nil), forCellReuseIdentifier: "\(cellClass)")
    }
    
    /// Cell reusable Identifier must be equal to cell class name
    func dequeueReusableCell<T: UITableViewCell>(with type: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: "\(type)", for: indexPath) as! T
    }
}
