//
//  NavigationManager.swift
//  RedRooster
//
//  Created by Woddi on 6/20/19.
//  Copyright © 2019 Anton Sakovych. All rights reserved.
//

import UIKit

//swiftlint:disable file_length
final class NavigationManager: NSObject {
    
    // MARK: Private properties
    private var controller: UIViewController?
    private var navController: UINavigationController?
        
    // MARK: - Public properties
    
    static var overCurrent: NavigationManager {
        let topController = UIApplication.topViewController()
        if let navigation = topController?.navigationController {
            return NavigationManager(navigation)
        } else {
            return NavigationManager(controller: topController)
        }
    }
    
    // MARK: - Initializer
    
    init(_ navigationController: UINavigationController? = nil) {
        navController = navigationController
    }

    private init(controller: UIViewController?) {
        self.controller = controller
    }
}

// MARK: SHOW methods
extension NavigationManager {
    
}

// MARK: PUSH methods
extension NavigationManager {
    
    func pushToMovieDetailViewController(with viewModel: MovieDetailViewModeling) {
        guard let controller = Storyboards.Main[MovieDetailViewController.self] else {
            return
        }

        controller.viewModel = viewModel
        viewModel.output = controller

        pushController(controller)
    }
}

// MARK: PRESENT

extension NavigationManager {
    
//    func showWalkthrough(with presenter: TutorialPresenter) {
//        guard let controller = Storyboards.Tutorial.initialViewController as? TutorialViewController else {
//            return
//        }
//
//        presenter.view = controller
//        controller.presenter = presenter
//
//        presentController(controller)
//    }
    
}

// MARK: SET methods
extension NavigationManager {
    
//    static func setOnboardingAsRoot() {
//        let controller = Storyboards.StoryboardName.controllerIdentifier
//        let someController = controller?.viewControllerAs(controller: SomeController.self)
//        let presenter = SomePresenter()
//        someController?.presenter = presenter
//        presenter.view = someController
//        switchRootViewController(controller)
//    }
//
    
    static func switchRootViewController(_ viewController: UIViewController?,
                                         duration: TimeInterval = 0.3,
                                         options: UIView.AnimationOptions = .transitionCrossDissolve,
                                         completion: ((Bool) -> Void)? = nil) {
        guard let window = UIApplication.shared.keyWindow else {
            if let window = UIApplication.shared.delegate?.window {
                window?.rootViewController = viewController
                window?.makeKeyAndVisible()
            }
            return
        }
        // added time delay for dismissing previous controller from stack
        // the same way if call this method in dismiss completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.transition(with: window, duration: duration, options: options, animations: {
                let oldState = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                UIApplication.shared.keyWindow?.rootViewController = viewController
                UIView.setAnimationsEnabled(oldState)
            }, completion: completion)
        }
    }
}

// MARK: - Private methods

private extension NavigationManager {
    
    func showController(_ controller: UIViewController) {
        (navController ?? self.controller)?.show(controller, sender: nil)
    }
    
    func pushController(_ controller: UIViewController) {
        navController?.pushViewController(controller, animated: true)
    }
    
    func presentController(_ controller: UIViewController) {
        (navController ?? self.controller)?.present(controller, animated: true)
    }
}
