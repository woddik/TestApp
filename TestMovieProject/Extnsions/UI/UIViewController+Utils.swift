//
//  UIViewController+Utils.swift
//  TestMovieProject
//
//  Created by Woddi on 19.01.2021.
//

import UIKit

extension UIViewController {
    
    var safeAreaBottomInset: CGFloat {
        return UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
    }
    
    var safeAreaTopInset: CGFloat {
        return UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
    }
    
    var isModal: Bool {
        return self.presentingViewController?.presentedViewController == self
            || (self.navigationController != nil &&
                self.navigationController?.presentingViewController?.presentedViewController == self.navigationController &&
            navigationController?.viewControllers[0] == self)
            || self.tabBarController?.presentingViewController is UITabBarController
    }
    
    static var topViewController: UIViewController {
        var topController = UIApplication.shared.keyWindow?.rootViewController
        while let presentedViewController = topController?.presentedViewController {
            topController = presentedViewController
        }
        
        return topController!
    }
    
    func showMessage(message: String, title: String, buttonTitle: String = "Ok", complition: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonTitle, style: .default) { _ in
            complition?()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func viewControllerAs<T: UIViewController>(controller: T.Type) -> T? {
        if let self = self as? T {
            return self
        } else if let nav = self as? UINavigationController, let searchController = nav.viewControllers.first as? T {
            return searchController
        }
        return nil
    }
}
