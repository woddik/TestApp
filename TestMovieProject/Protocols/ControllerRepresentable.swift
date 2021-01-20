//
//  ControllerRepresentable.swift
//  TestMovieProject
//
//  Created by Woddi on 20.01.2021.
//

import UIKit

protocol ControllerRepresentable {
    
    static var initialViewController: UIViewController? { get }
    
}

extension ControllerRepresentable {
    
    static var initialViewController: UIViewController? {
        return UIStoryboard(name: "\(self.self)", bundle: nil).instantiateInitialViewController()
    }
    
}

extension ControllerRepresentable where Self: RawRepresentable, Self.RawValue == String {
    
    var controller: UIViewController {
        return UIStoryboard(name: "\(type(of: self))", bundle: nil)
            .instantiateViewController(withIdentifier: rawValue.capitalizedFirstChar)
    }

    func `as`<U: UIViewController>(_ cType: U.Type) -> U? {
        return controller as? U
    }
    
    static func controllerWithEqualNameTo<U: UIViewController>(type: U.Type) -> U? {
        return self.init(rawValue: "\(type)".lowercasedFirstChar)?.as(type)
    }
    
    static subscript<U: UIViewController>(type: U.Type) -> U? {
        return controllerWithEqualNameTo(type: type)
    }
}

fileprivate extension String {
    
    var capitalizedFirstChar: String {
        guard let firstChar = first else {
            return ""
        }
        return String(firstChar).uppercased() + dropFirst()
    }
    
    var lowercasedFirstChar: String {
        guard let firstChar = first else {
            return ""
        }
        return String(firstChar).lowercased() + dropFirst()
    }
    
}
