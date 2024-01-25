//
//  AppDelegate.swift
//  NavigationViewTransition
//
//  Created by lidan on 2024/1/24.
//

import UIKit
import ObjectiveC

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Runtime.implementationOfVoidMethodWithoutArguments(targetClass: UIViewController.self,
                                                           targetSelector: #selector(UIViewController.viewDidLoad)) { selfObject in
            (selfObject as? UIViewController)?.view.backgroundColor = .yellow
            print(selfObject)
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        
        return true
    }
}

