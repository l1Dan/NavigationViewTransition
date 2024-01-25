//
//  UINavigationController+Extension.swift
//  NavigationViewTransition
//
//  Created by lidan on 2024/1/25.
//

import UIKit

extension UINavigationController {
    var nx_useNavigationBar: Bool {
        return true
    }
    
    func nx_viewController(_ currentViewController: UIViewController,
                           preparePopViewController destinationViewController: UIViewController,
                           action: NavigationTransition.Action) -> Bool {
        return true
    }
}

extension UINavigationController {
    static func overrideImplementations() {
        Runtime.overrideImplementation(targetClass: UINavigationController.self,
                                       targetSelector: NSSelectorFromString("_tryRequestPopToItem")) { originClass, originCMD, originalIMPProvider in
            let block: @convention(block) (UINavigationController, UINavigationItem) -> Bool = { selfObject, item in
                if let topViewController = selfObject.topViewController, selfObject.nx_useNavigationBar {
                    var destinationViewController = topViewController
                    selfObject.viewControllers.forEach { viewController in
                        if viewController.navigationItem == item {
                            destinationViewController = viewController
                        }
                    }
                    
                    if !selfObject.nx_viewController(topViewController, preparePopViewController: destinationViewController, action: .clickBackButtonMenu) {
                        return false
                    }
                }
                
                // call super
                typealias originSelectorIMPType = @convention(c) (AnyObject, Selector, UINavigationItem) -> Bool
                let originSelectorIMP = unsafeBitCast(originalIMPProvider(), to: originSelectorIMPType.self)
                return originSelectorIMP(selfObject, originCMD, item)
            }
            return block
        }
        
        Runtime.overrideImplementation(targetClass: NSClassFromString("_UINavigationBarContentView"),
                                       targetSelector: NSSelectorFromString("__backButtonAction:")) { originClass, originCMD, originalIMPProvider in
            let block: @convention(block) (UIView, AnyObject) -> Void = { selfObject, firstArgv in
                if let bar = selfObject.superview as? UINavigationBar,
                   let navigationController = bar.delegate as? UINavigationController,
                   let topViewController = navigationController.topViewController,
                    navigationController.nx_useNavigationBar {
                    let viewControllers = navigationController.viewControllers
                    let destinationViewController = viewControllers.count >= 2 ? viewControllers[viewControllers.count - 2] : topViewController
                    if !navigationController.nx_viewController(topViewController, preparePopViewController: destinationViewController, action: .clickBackButton) {
                        return
                    }
                }
                
                // call super
                typealias originSelectorIMPType = @convention(c) (UIView, Selector, AnyObject) -> Void
                let originSelectorIMP = unsafeBitCast(originalIMPProvider(), to: originSelectorIMPType.self)
                originSelectorIMP(selfObject, originCMD, firstArgv)
            }
            return block
        }
        
        Runtime.overrideImplementation(targetClass: UINavigationController.self,
                                       targetSelector: #selector(UINavigationController.pushViewController(_:animated:))) { originClass, originCMD, originalIMPProvider in
            let block: @convention(block) (UINavigationController, UIViewController, Bool) -> Void = { selfObject, viewController, animated in
                // call super
                let callSuperBlock = {
                    typealias originSelectorIMPType = @convention(c) (UINavigationController, Selector, UIViewController, Bool) -> Void
                    let originSelectorIMP = unsafeBitCast(originalIMPProvider(), to: originSelectorIMPType.self)
                    originSelectorIMP(selfObject, originCMD, viewController, animated)
                }
                
                if !selfObject.nx_useNavigationBar {
                    callSuperBlock()
                    return
                }
                
                if selfObject.presentedViewController != nil {
                    debugPrint("push 的时候 UINavigationController 存在一个盖在上面的 presentedViewController，可能导致一些 UINavigationControllerDelegate 不会被调用")
                }
                
                if selfObject.viewControllers.contains(viewController) {
                    debugPrint("不允许重复 push 相同的 viewController 实例，会产生 crash。当前 viewController：\(viewController)")
                    return
                }
                
                
            }
            return block
        }


        //
        //        NXNavigationExtensionOverrideImplementation([UINavigationController class],
        //                                                    @selector(pushViewController:animated:),
        //                                                    ^id _Nonnull(__unsafe_unretained Class _Nonnull originClass, SEL _Nonnull originCMD, IMP _Nonnull (^_Nonnull originalIMPProvider)(void)) {
        //            return ^(UINavigationController *selfObject, UIViewController *viewController, BOOL animated) {
 
        //
        //                BOOL willPushActually = viewController && ![viewController isKindOfClass:UITabBarController.class] && ![selfObject.viewControllers containsObject:viewController];
        //                if (!willPushActually) {
        //                    callSuperBlock();
        //                    return;
        //                }
        //
        //                viewController.navigationItem.nx_viewController = viewController;
        //                // 先赋值一次
        //                viewController.nx_configuration = selfObject.nx_configuration;
        //                viewController.nx_prepareConfigureViewControllerCallback = selfObject.nx_prepareConfigureViewControllerCallback;
        //                // 设置返回按钮
        //                [selfObject nx_adjustmentSystemBackButtonForViewController:viewController inViewControllers:selfObject.viewControllers];
        //
        //                if (selfObject.viewControllers.count > 0) {
        //                    [viewController nx_configureNavigationBarWithNavigationController:selfObject];
        //                }
        //                // 重新检查返回手势是否动态修改
        //                [selfObject nx_configureInteractivePopGestureRecognizerWithViewController:viewController];
        //
        //                UIViewController *appearingViewController = viewController;
        //                [selfObject nx_processViewController:appearingViewController navigationAction:NXNavigationActionWillPush];
        //
        //                callSuperBlock();
        //
        //                [selfObject nx_processViewController:appearingViewController navigationAction:NXNavigationActionDidPush];
        //
        //                [selfObject nx_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        //                    NXNavigationAction navigationAction = context.isCancelled ? NXNavigationActionPushCancelled : NXNavigationActionPushCompleted;
        //                    [selfObject nx_processViewController:appearingViewController navigationAction:navigationAction];
        //                    [selfObject nx_processViewController:appearingViewController navigationAction:NXNavigationActionUnspecified];
        //                }];
        //            };
        //        });
        //
        //        NXNavigationExtensionOverrideImplementation([UINavigationController class],
        //                                                    @selector(popViewControllerAnimated:),
        //                                                    ^id _Nonnull(__unsafe_unretained Class _Nonnull originClass, SEL _Nonnull originCMD, IMP _Nonnull (^_Nonnull originalIMPProvider)(void)) {
        //            return ^UIViewController *(UINavigationController *selfObject, BOOL animated) {
        //                // call super
        //                UIViewController * (^callSuperBlock)(void) = ^UIViewController *(void) {
        //                    UIViewController *(*originSelectorIMP)(id, SEL, BOOL);
        //                    originSelectorIMP = (UIViewController * (*)(id, SEL, BOOL)) originalIMPProvider();
        //                    UIViewController *result = originSelectorIMP(selfObject, originCMD, animated);
        //                    return result;
        //                };
        //
        //                if (!selfObject.nx_useNavigationBar) {
        //                    return callSuperBlock();
        //                }
        //
        //                NXNavigationAction action = selfObject.nx_navigationAction;
        //                if (action != NXNavigationActionUnspecified) {
        //                    NXDebugLog(@"popViewController 时上一次的转场尚未完成，系统会忽略本次 pop，等上一次转场完成后再重新执行 pop, viewControllers = %@", selfObject.viewControllers);
        //                }
        //
        //                // 系统文档里说 rootViewController 是不能被 pop 的，当只剩下 rootViewController 时当前方法什么事都不会做
        //                BOOL willPopActually = selfObject.viewControllers.count > 1 && action == NXNavigationActionUnspecified;
        //                if (!willPopActually) {
        //                    return callSuperBlock();
        //                }
        //
        //                UIViewController *appearingViewController = selfObject.viewControllers[selfObject.viewControllers.count - 2];
        //                [selfObject nx_processViewController:appearingViewController navigationAction:NXNavigationActionWillPop];
        //
        //                UIViewController *result = callSuperBlock();
        //
        //                [selfObject nx_processViewController:appearingViewController navigationAction:NXNavigationActionDidPop];
        //                [selfObject nx_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        //                    NXNavigationAction navigationAction = context.isCancelled ? NXNavigationActionPopCancelled : NXNavigationActionPopCompleted;
        //                    [selfObject nx_processViewController:appearingViewController navigationAction:navigationAction];
        //                    [selfObject nx_processViewController:appearingViewController navigationAction:NXNavigationActionUnspecified];
        //                }];
        //
        //                return result;
        //            };
        //        });
        //
        //        NXNavigationExtensionOverrideImplementation([UINavigationController class],
        //                                                    @selector(popToViewController:animated:),
        //                                                    ^id _Nonnull(__unsafe_unretained Class _Nonnull originClass, SEL _Nonnull originCMD, IMP _Nonnull (^_Nonnull originalIMPProvider)(void)) {
        //            return ^NSArray<UIViewController *> *(UINavigationController *selfObject, UIViewController *viewController, BOOL animated) {
        //                // call super
        //                NSArray<UIViewController *> * (^callSuperBlock)(void) = ^NSArray<UIViewController *> *(void) {
        //                    NSArray<UIViewController *> *(*originSelectorIMP)(id, SEL, UIViewController *, BOOL);
        //                    originSelectorIMP = (NSArray<UIViewController *> * (*)(id, SEL, UIViewController *, BOOL)) originalIMPProvider();
        //                    NSArray<UIViewController *> *disappearingViewControllers = originSelectorIMP(selfObject, originCMD, viewController, animated);
        //                    return disappearingViewControllers;
        //                };
        //
        //                if (!selfObject.nx_useNavigationBar) {
        //                    return callSuperBlock();
        //                }
        //
        //                NXNavigationAction action = selfObject.nx_navigationAction;
        //                if (action != NXNavigationActionUnspecified) {
        //                    NXDebugLog(@"popToViewController 时上一次的转场尚未完成，系统会忽略本次 pop，等上一次转场完成后再重新执行 pop, currentViewControllers = %@, viewController = %@", selfObject.viewControllers, viewController);
        //                }
        //
        //                // 系统文档里说 rootViewController 是不能被 pop 的，当只剩下 rootViewController 时当前方法什么事都不会做
        //                BOOL willPopActually = selfObject.viewControllers.count > 1 && [selfObject.viewControllers containsObject:viewController] && selfObject.topViewController != viewController && action == NXNavigationActionUnspecified;
        //                if (!willPopActually) {
        //                    return callSuperBlock();
        //                }
        //
        //                UIViewController *appearingViewController = viewController;
        //                [selfObject nx_processViewController:appearingViewController navigationAction:NXNavigationActionWillPop];
        //
        //                NSArray<UIViewController *> *result = callSuperBlock();
        //
        //                [selfObject nx_processViewController:appearingViewController navigationAction:NXNavigationActionDidPop];
        //                [selfObject nx_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        //                    NXNavigationAction navigationAction = context.isCancelled ? NXNavigationActionPopCancelled : NXNavigationActionPopCompleted;
        //                    [selfObject nx_processViewController:appearingViewController navigationAction:navigationAction];
        //                    [selfObject nx_processViewController:appearingViewController navigationAction:NXNavigationActionUnspecified];
        //                }];
        //
        //                return result;
        //            };
        //        });
        //
        //        NXNavigationExtensionOverrideImplementation([UINavigationController class],
        //                                                    @selector(popToRootViewControllerAnimated:),
        //                                                    ^id _Nonnull(__unsafe_unretained Class _Nonnull originClass, SEL _Nonnull originCMD, IMP _Nonnull (^_Nonnull originalIMPProvider)(void)) {
        //            return ^NSArray<UIViewController *> *(UINavigationController *selfObject, BOOL animated) {
        //                // call super
        //                NSArray<UIViewController *> * (^callSuperBlock)(void) = ^NSArray<UIViewController *> *(void) {
        //                    NSArray<UIViewController *> *(*originSelectorIMP)(id, SEL, BOOL);
        //                    originSelectorIMP = (NSArray<UIViewController *> * (*)(id, SEL, BOOL)) originalIMPProvider();
        //                    NSArray<UIViewController *> *result = originSelectorIMP(selfObject, originCMD, animated);
        //                    return result;
        //                };
        //
        //                if (!selfObject.nx_useNavigationBar) {
        //                    return callSuperBlock();
        //                }
        //
        //                NXNavigationAction action = selfObject.nx_navigationAction;
        //                if (action != NXNavigationActionUnspecified) {
        //                    NXDebugLog(@"popToRootViewController 时上一次的转场尚未完成，系统会忽略本次 pop，等上一次转场完成后再重新执行 pop, viewControllers = %@", selfObject.viewControllers);
        //                }
        //
        //                BOOL willPopActually = selfObject.viewControllers.count > 1 && action == NXNavigationActionUnspecified;
        //                if (!willPopActually) {
        //                    return callSuperBlock();
        //                }
        //
        //                UIViewController *appearingViewController = selfObject.viewControllers.firstObject;
        //                [selfObject nx_processViewController:appearingViewController navigationAction:NXNavigationActionWillPop];
        //
        //                NSArray<UIViewController *> *result = callSuperBlock();
        //
        //                [selfObject nx_processViewController:appearingViewController navigationAction:NXNavigationActionDidPop];
        //                [selfObject nx_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        //                    NXNavigationAction navigationAction = context.isCancelled ? NXNavigationActionPopCancelled : NXNavigationActionPopCompleted;
        //                    [selfObject nx_processViewController:appearingViewController navigationAction:navigationAction];
        //                    [selfObject nx_processViewController:appearingViewController navigationAction:NXNavigationActionUnspecified];
        //                }];
        //
        //                return result;
        //            };
        //        });
        //
        //        NXNavigationExtensionOverrideImplementation([UINavigationController class],
        //                                                    @selector(setViewControllers:animated:),
        //                                                    ^id _Nonnull(__unsafe_unretained Class _Nonnull originClass, SEL _Nonnull originCMD, IMP _Nonnull (^_Nonnull originalIMPProvider)(void)) {
        //            return ^(UINavigationController *selfObject, NSArray<UIViewController *> *viewControllers, BOOL animated) {
        //                // call super
        //                void (^callSuperBlock)(void) = ^{
        //                    void (*originSelectorIMP)(id, SEL, NSArray<UIViewController *> *, BOOL);
        //                    originSelectorIMP = (void (*)(id, SEL, NSArray<UIViewController *> *, BOOL))originalIMPProvider();
        //                    originSelectorIMP(selfObject, originCMD, viewControllers, animated);
        //                };
        //
        //                if (!selfObject.nx_useNavigationBar) {
        //                    callSuperBlock();
        //                    return;
        //                }
        //
        //                if (viewControllers.count != [NSSet setWithArray:viewControllers].count) {
        //                    NXDebugLog(@"setViewControllers 数组里不允许出现重复元素：%@", viewControllers);
        //                    viewControllers = [NSOrderedSet orderedSetWithArray:viewControllers].array; // 这里会保留该 vc 第一次出现的位置不变
        //                }
        //
        //                for (UIViewController *viewController in viewControllers) {
        //                    viewController.navigationItem.nx_viewController = viewController;
        //                    // 先赋值一次
        //                    viewController.nx_configuration = selfObject.nx_configuration;
        //                    viewController.nx_prepareConfigureViewControllerCallback = selfObject.nx_prepareConfigureViewControllerCallback;
        //                }
        //
        //                if (viewControllers.count > 1) {
        //                    NSMutableArray<__kindof UIViewController *> *previousViewControllers = [NSMutableArray array];
        //                    for (NSUInteger index = 0; index < viewControllers.count; index++) {
        //                        UIViewController *viewController = viewControllers[index];
        //
        //                        if (index != 0) {
        //                            // 设置返回按钮
        //                            [selfObject nx_adjustmentSystemBackButtonForViewController:viewController inViewControllers:previousViewControllers];
        //                            [viewController nx_configureNavigationBarWithNavigationController:selfObject];
        //                        }
        //                        [previousViewControllers addObject:viewController];
        //                        // 重新检查返回手势是否动态修改
        //                        [selfObject nx_configureInteractivePopGestureRecognizerWithViewController:viewController];
        //                    }
        //                }
        //
        //                // setViewControllers 执行前后 topViewController 没有变化，则赋值为 nil，表示没有任何界面有“重新显示”。
        //                UIViewController *appearingViewController = selfObject.topViewController != viewControllers.lastObject ? viewControllers.lastObject : nil;
        //                [selfObject nx_processViewController:appearingViewController navigationAction:NXNavigationActionWillSet];
        //
        //                callSuperBlock();
        //
        //                [selfObject nx_processViewController:appearingViewController navigationAction:NXNavigationActionDidSet];
        //                [selfObject nx_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        //                    NXNavigationAction navigationAction = context.isCancelled ? NXNavigationActionSetCancelled : NXNavigationActionSetCompleted;
        //                    [selfObject nx_processViewController:appearingViewController navigationAction:navigationAction];
        //                    [selfObject nx_processViewController:appearingViewController navigationAction:NXNavigationActionUnspecified];
        //                }];
        //            };
        //        });
        //    });
    }
}

extension NavigationTransitionWrapper where Base: UINavigationController {
    func pushViewController(_ viewController: UIViewController,
                                   animated: Bool,
                                   completion: (() -> Void)? = nil) {
        
    }

    
    func popViewController(animated: Bool,
                                  completion: (() -> Void)? = nil) -> UIViewController? {
        return nil
    }

    func popToViewController(_ viewController: UIViewController,
                                    animated: Bool,
                                    completion: (() -> Void)? = nil) -> [UIViewController]? {
        return nil
    }

    func popToRootViewController(animated: Bool,
                                        completion: (() -> Void)? = nil) -> [UIViewController]? {
        return nil
    }
    
    func popAndPushViewController(_ viewControllerToPush: UIViewController,
                                   animated: Bool,
                                   completion: (() -> Void)? = nil) -> UIViewController? {
        return nil
    }

    func popToViewController(_ viewController: UIViewController,
                                    andPush viewControllerToPush: UIViewController,
                                    animated: Bool,
                                    completion: (() -> Void)? = nil) -> [UIViewController]? {
        return nil
    }

    func popToRootViewControllerAndPush(_ viewControllerToPush: UIViewController,
                                               animated: Bool,
                                               completion: (() -> Void)? = nil) -> [UIViewController]? {
        return nil
    }
    
    func setViewControllers(_ viewControllers: [UIViewController],
                                   animated: Bool,
                                   completion: (() -> Void)? = nil) {
        
    }
}
