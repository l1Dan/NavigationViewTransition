//
//  NavigationView.swift
//  NavigationViewTransition
//
//  Created by lidan on 2024/1/24.
//

import UIKit

class NavigationView: UIView {
    private(set) lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private(set) lazy var shadowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private(set) lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private(set) lazy var backgroundEffectView: UIVisualEffectView = {
        var effect = UIBlurEffect(style: .extraLight)
        if #available(iOS 13.0, *) {
            effect = UIBlurEffect(style: .systemChromeMaterial)
        }
        let visualEffectView = UIVisualEffectView(effect: effect)
        visualEffectView.isHidden = true
        return visualEffectView
    }()
    
    private(set) var contentViewEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8) {
        didSet { updateSubviewsFrame(frame, callSuper: false) }
    }
    
    private var originalBackgroundColor: UIColor?
    private var originalNavigationBarFrame: CGRect = .zero
    
    private var blurEffectEnabled: Bool = false {
        didSet { backgroundColor = originalBackgroundColor }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(backgroundImageView)
        addSubview(backgroundEffectView)
        addSubview(shadowImageView)
        addSubview(contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateSubviewsFrame(frame, callSuper: false)
    }
    
    override var frame: CGRect {
        get { return super.frame }
        set { updateSubviewsFrame(newValue, callSuper: true) }
    }
    
    override var backgroundColor: UIColor? {
        get { return super.backgroundColor }
        set {
            originalBackgroundColor = newValue
            if blurEffectEnabled {
                backgroundImageView.isHidden = true
                backgroundEffectView.isHidden = false
                backgroundEffectView.contentView.backgroundColor = newValue
                super.backgroundColor = .clear
            } else {
                backgroundImageView.isHidden = false
                backgroundEffectView.isHidden = true
                backgroundEffectView.contentView.backgroundColor = .clear
                super.backgroundColor = newValue
            }
        }
    }
    
    override var isHidden: Bool {
        get { return super.isHidden }
        set { contentView.isHidden = newValue }
    }
    
    override var isUserInteractionEnabled: Bool {
        get { return super.isUserInteractionEnabled }
        set { contentView.isUserInteractionEnabled = newValue }
    }
    
    override var semanticContentAttribute: UISemanticContentAttribute {
        get { return super.semanticContentAttribute }
        set { setSubviews(semanticContentAttribute: newValue) }
    }
}

extension NavigationView {
    private func setSubviews(semanticContentAttribute: UISemanticContentAttribute) {
        subviews.forEach { $0.semanticContentAttribute = semanticContentAttribute }
    }
    
    private func updateSubviewsFrame(_ frame: CGRect, callSuper: Bool) {
        let navigationBarFrame = CGRect(x: 0, y: 0, width: originalNavigationBarFrame.width, height: originalNavigationBarFrame.maxY)
        backgroundImageView.frame = navigationBarFrame
        backgroundEffectView.frame = navigationBarFrame
        
        let contentViewFrame = CGRect(x: 0, y: originalNavigationBarFrame.minY, width: originalNavigationBarFrame.width, height: originalNavigationBarFrame.height)
        contentView.frame = contentViewFrame.inset(by: contentViewEdgeInsets.nt.insets(of: semanticContentAttribute))

        let shadowImageViewHeight = 1.0 / UIScreen.main.scale
        shadowImageView.frame = CGRect(x: 0, y: originalNavigationBarFrame.maxY - shadowImageViewHeight, width: navigationBarFrame.width, height: shadowImageViewHeight)
        
        if callSuper {
            let navigationBarY = frame.minY - originalNavigationBarFrame.minY
            super.frame = CGRect(x: 0, y: navigationBarY, width: originalNavigationBarFrame.width, height: originalNavigationBarFrame.maxY)
        } else if let superview, let aClass = NSClassFromString("_UIParallaxDimmingView"), superview.isKind(of: aClass) {
            // fix: Use edgesForExtendedLayoutEnabled instance in UITableViewController & UICollectionViewController
            let navigationBarY = superview.frame.minY - originalNavigationBarFrame.minY
            self.frame = CGRect(x: 0, y: -navigationBarY, width: originalNavigationBarFrame.width, height: originalNavigationBarFrame.maxY)
        }
    }
}

extension NavigationTransitionWrapper where Base == UIEdgeInsets {
    func insets(of semanticContentAttribute: UISemanticContentAttribute) -> UIEdgeInsets {
        if semanticContentAttribute == .forceRightToLeft {
            return UIEdgeInsets(top: base.top, left: base.right, bottom: base.bottom, right: base.left)
        }
        return base
    }
}
