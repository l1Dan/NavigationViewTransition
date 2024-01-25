//
//  Configuration.swift
//  NavigationViewTransition
//
//  Created by lidan on 2024/1/24.
//

import UIKit

class Configuration {
    enum Distance {
        case `default`
        case maxAllowed(CGFloat)
    }
}

class ConfigurationProvider {
    private var backgroundClosure: (() -> NavigationView.Background)?
    private var backButtonClosure: (() -> NavigationView.BackButton)?
    private var shadowClosure: (() -> NavigationView.Shadow)?
    private var tintColorClosure: (() -> UIColor)?
    private var barTintColorClosure: (() -> UIColor)?
    private var titleAttributesClosure: (() -> [NSAttributedString.Key: Any])?
    private var largeTitleAttributesClosure: (() -> [NSAttributedString.Key: Any])?
    
    private var fullScreenInteractivePopGestureClosure: (() -> Configuration.Distance)?
    private var systemNavigationBarEnabledClosure: (() -> Bool)?
    private var hidesNavigationBarInChildViewControllerClosure: (() -> Bool)?
    
    static var provider = ConfigurationProvider()

    func background(_ closure: @autoclosure @escaping () -> NavigationView.Background) -> Self {
        backgroundClosure = closure
        return self
    }
    
    func tintColor(_ closure: @autoclosure @escaping () -> UIColor) -> Self {
        tintColorClosure = closure
        return self
    }
    
    func barTintColor(_ closure: @autoclosure @escaping () -> UIColor) -> Self {
        barTintColorClosure = closure
        return self
    }
    
    func shadow(_ closure: @autoclosure @escaping () -> NavigationView.Shadow) -> Self {
        shadowClosure = closure
        return self
    }
    
    func backButton(_ closure: @autoclosure @escaping () -> NavigationView.BackButton) -> Self {
        backButtonClosure = closure
        return self
    }
    
    func titleAttributes(_ closure: @autoclosure @escaping () -> [NSAttributedString.Key : Any]) -> Self {
        titleAttributesClosure = closure
        return self
    }
    
    func largeTitleAttributes(_ closure: @autoclosure @escaping () -> [NSAttributedString.Key : Any]) -> Self {
        largeTitleAttributesClosure = closure
        return self
    }
    
    func fullScreenInteractivePopGesture(_ closure: @autoclosure @escaping () -> Configuration.Distance) -> Self {
        fullScreenInteractivePopGestureClosure = closure
        return self
    }
    
    func hidesNavigationBarInChildViewController(_ closure: @autoclosure @escaping () -> Bool) -> Self {
        hidesNavigationBarInChildViewControllerClosure = closure
        return self
    }
    
    func systemNavigationBarEnabled(_ closure: @autoclosure @escaping () -> Bool) -> Self {
        systemNavigationBarEnabledClosure = closure
        return self
    }
    
    func onBackActionHandler(_ close: ((_ viewController: UIViewController, _ backAction: NavigationTransition.Action) -> Bool)) -> Self {
        return self
    }
}

