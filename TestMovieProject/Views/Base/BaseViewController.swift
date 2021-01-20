//
//  BaseViewController.swift
//  TestMovieProject
//
//  Created by Woddi on 19.01.2021.
//

import UIKit

class BaseViewController: UIViewController {
    
    private(set) lazy var loader: Loader = .loader(withY: loaderPosition)

    private(set) var calculateLoaderUnderNavigation = true

    var underNavigationDistance: CGFloat? {
        guard let navBar = navigationController?.navigationBar,
            let windowView = UIApplication.shared.windows.first else {
            return nil
        }
        
        let newFrame = windowView.convert(navBar.frame, to: navBar)
        if newFrame.origin.y < 0 {
            return abs(newFrame.origin.y) + newFrame.height //+ safeAreaTopInset
        } else {
            return newFrame.height + safeAreaTopInset
        }
    }

    var loaderPosition: Loader.PositionY {
        if calculateLoaderUnderNavigation {
            guard let undedrNavigationDistance = underNavigationDistance else {
                return .medium
            }
            
            return .custom(value: undedrNavigationDistance)
        }
        return .default
    }
    
}







