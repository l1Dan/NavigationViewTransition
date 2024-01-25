//
//  Extensions.swift
//  NavigationViewTransition
//
//  Created by lidan on 2024/1/24.
//

import UIKit

struct NavigationTransition {
    enum State {
        case unspecified    // 初始、各种动作的 completed 之后都会立即转入 unspecified 状态
        
        case willPush       // push 方法被触发，但尚未进行真正的 push 动作
        case didPush        // 系统的 push 已经执行完，viewControllers 已被刷新
        case pushCancelled  // 系统的 push 被取消，还是停留在当前页面
        case pushCompleted  // push 动画结束（如果没有动画，则在 did push 后立即进入 completed）
        
        case willPop        // pop 方法被触发，但尚未进行真正的 pop 动作
        case didPop         // 系统的 pop 已经执行完，viewControllers 已被刷新（注意可能有 pop 失败的情况）
        case popCancelled   // 系统的 pop 被取消，还是停留在当前页面
        case popCompleted   // pop 动画结束（如果没有动画，则在 did pop 后立即进入 completed）
        
        case willSet        // setViewControllers 方法被触发，但尚未进行真正的 set 动作
        case didSet         // 系统的 setViewControllers 已经执行完，viewControllers 已被刷新
        case setCancelled   // 系统的 setViewControllers 被取消，还是停留在当前页面
        case setCompleted   // setViewControllers 动画结束（如果没有动画，则在 did set 后立即进入 completed）
    }
    
    enum Action {
        case callingNXPopMethod
        case clickBackButton
        case clickBackButtonMenu
        case InteractionGesture
    }
}

extension NavigationView {
    enum Shadow {
        case image(UIImage)
        case color(UIColor)
    }

    enum Background {
        case translucent
        case image(UIImage)
        case color(UIColor)
        case blur(UIColor)
    }
    
    enum BackButton {
        enum System {
            case `default`
            case titled(String)
        }
        
        enum Custom {
            case view(UIView)
            case backIndicator(image: UIImage)
            case backIndicator(image: UIImage, insets: UIEdgeInsets = .zero)
            case backIndicator(image: UIImage, insets: UIEdgeInsets = .zero, landscapeImage: UIImage, landscapeInset: UIEdgeInsets = .zero)
        }
        
        enum Style {
            case system(System)
            case custom(Custom)
        }
    }
}

