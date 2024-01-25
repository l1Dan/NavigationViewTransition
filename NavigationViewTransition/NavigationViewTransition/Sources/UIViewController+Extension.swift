//
//  UIViewController+Extension.swift
//  NavigationViewTransition
//
//  Created by lidan on 2024/1/25.
//

import UIKit


extension NavigationTransitionWrapper where Base: UIViewController {
    func popAndPresent(_ viewControllerToPresent: UIViewController,
                              animated: Bool,
                              completion: (() -> Void)? = nil) -> UIViewController? {
        return nil
    }
    
    func popToViewController(_ viewController: UIViewController,
                                    andPresent viewControllerToPresent: UIViewController,
                                    animated: Bool,
                                    completion: (() -> Void)? = nil) -> UIViewController? {
        return nil
    }
    
    func popToRootViewControllerAndPresent(_ viewControllerToPresent: UIViewController,
                                                  animated: Bool,
                                                  completion: (() -> Void)? = nil) -> [UIViewController]? {
        return nil
    }
}
