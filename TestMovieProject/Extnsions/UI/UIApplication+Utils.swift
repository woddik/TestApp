//
//  UIApplication+Utils.swift
//  TestMovieProject
//
//  Created by Woddi on 20.01.2021.
//

import UIKit

extension UIApplication {
    
    static func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let navigationController = base as? UINavigationController, navigationController.viewControllers.count > 0 {
            return topViewController(navigationController.visibleViewController)
        }
        
        if let tabBarController = base as? UITabBarController {
            if let selected = tabBarController.selectedViewController {
                return topViewController(selected)
            }
        }
        
        if let presentedViewController = base?.presentedViewController {
            return topViewController(presentedViewController)
        }
        
        return base
    }
}
