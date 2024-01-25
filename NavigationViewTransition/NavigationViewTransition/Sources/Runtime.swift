//
//  Runtime.swift
//  NavigationViewTransition
//
//  Created by lidan on 2024/1/25.
//

import Foundation
import ObjectiveC

struct Runtime {
    private init() { }
    
    private static func hasOverrideSuperclassMethod(targetClass: AnyClass?, targetSelector: Selector) -> Bool {
        if let method = class_getInstanceMethod(targetClass, targetSelector) {
            if let methodOfSuperclass = class_getInstanceMethod(class_getSuperclass(targetClass), targetSelector) {
                return method != methodOfSuperclass
            }
            return true
        }
        return false
    }
    
    static func overrideImplementation(targetClass: AnyClass?, 
                                       targetSelector: Selector,
                                       implementationBlock: (_ originClass: AnyClass?, _ originCMD: Selector, _ originalIMPProvider: @escaping () -> IMP) -> Any) {
        guard let originMethod = class_getInstanceMethod(targetClass, targetSelector) else { return }
        let imp = method_getImplementation(originMethod)
        let hasOverride = Runtime.hasOverrideSuperclassMethod(targetClass: targetClass, targetSelector: targetSelector)
        
        let originalIMPProvider: () -> IMP = {
            if hasOverride {
                return imp
            }
            
            if let imp = class_getMethodImplementation(class_getSuperclass(targetClass), targetSelector) {
                return imp
            }
            let block: @convention(block) (AnyObject) -> Void = { selfObject in
                debugPrint(selfObject)
            }
            return imp_implementationWithBlock(block)
        }
        
        let block = imp_implementationWithBlock(implementationBlock(targetClass, targetSelector, originalIMPProvider))
        if hasOverride {
            method_setImplementation(originMethod, block)
        } else {
            let types = method_getTypeEncoding(originMethod)
            class_addMethod(targetClass, targetSelector, block, types)
        }
    }
    
    static func implementationOfVoidMethodWithoutArguments(targetClass: AnyClass?,
                                                           targetSelector: Selector, implementationBlock: @escaping (_ selfObject: AnyObject) -> Void) {
        overrideImplementation(targetClass: targetClass, targetSelector: targetSelector) { originClass, originCMD, originalIMPProvider in
            let block: @convention(block) (AnyObject) -> Void = { selfObject in
                typealias originSelectorIMPType = @convention(c) (AnyObject, Selector) -> Void
                let originSelectorIMP = unsafeBitCast(originalIMPProvider(), to: originSelectorIMPType.self)
                originSelectorIMP(selfObject, originCMD)
                implementationBlock(selfObject)
            }
            return block
        }
    }
        
}
