//
//  NavigationViewTransition.swift
//  NavigationViewTransition
//
//  Created by lidan on 2024/1/24.
//

import Foundation


struct NavigationTransitionWrapper<Base> {
    let base: Base
    
    init(_ base: Base) {
        self.base = base
    }
}

protocol NavigationTransitionCompatible: AnyObject { }

extension NavigationTransitionCompatible {
    var nt: NavigationTransitionWrapper<Self> {
        get { return NavigationTransitionWrapper(self) }
        set { }
    }
}

protocol NavigationTransitionCompatibleValue { }

extension NavigationTransitionCompatibleValue {
    var nt: NavigationTransitionWrapper<Self> {
        get { return NavigationTransitionWrapper(self) }
        set { }
    }
}


import UIKit

extension UIEdgeInsets: NavigationTransitionCompatibleValue { }

extension UIViewController: NavigationTransitionCompatible { }
