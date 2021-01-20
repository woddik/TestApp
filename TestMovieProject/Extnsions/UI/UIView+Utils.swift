//
//  UIView+Utils.swift
//  TestMovieProject
//
//  Created by Woddi on 19.01.2021.
//

import UIKit

extension UIView {
    
    enum ConstraintType {
        case height
        case width
    }
    
    enum Result {
        case constraint(NSLayoutConstraint)
        case anchor(NSLayoutDimension)
        
        init(con: NSLayoutConstraint?, anc: NSLayoutDimension) {
            if let con = con {
                self = .constraint(con)
            } else {
                self = .anchor(anc)
            }
        }
        
        func setConstant(_ value: CGFloat) {
            switch self {
            case .constraint(let con):
                con.constant = value
            case .anchor(let anc):
                anc.constraint(equalToConstant: value).isActive = true
            }
        }
        
        func appendToActiveConstsraint(value: CGFloat) {
            switch self {
            case .constraint(let con):
                con.constant += value
            case .anchor:
                break
            }
        }
    }
    
    func findConstraint(by type: ConstraintType) -> Result {
        var tmpConstr: NSLayoutDimension
        switch type {
        case .height: tmpConstr = heightAnchor
        case .width: tmpConstr = widthAnchor
        }
        
        return Result(con: constraints.first(where: { $0 == tmpConstr }), anc: tmpConstr)
    }
}
