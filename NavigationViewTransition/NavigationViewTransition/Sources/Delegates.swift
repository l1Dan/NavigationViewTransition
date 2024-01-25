//
//  Delegates.swift
//  NavigationViewTransition
//
//  Created by lidan on 2024/1/24.
//

import UIKit

class ScreenEdgePopGestureRecognizerDelegate: NSObject {
    weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
}

class FullScreenPopGestureRecognizerDelegate: NSObject {
    weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
}
