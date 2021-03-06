//
//  MenuController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 2/14/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

class MenuController
{
    private let animationDuration = 0.12
    private(set) var isShowing: Bool = false
    private let verticalOffset: CGFloat
    private let menu: UIStackView
    private let targetViewController: UIViewController
    private let blurEffect: UIVisualEffectView
    
    init(withStackView stackView: UIStackView, inViewController vc: UIViewController, withYOffset yOffset: Double) {
        self.menu = stackView
        self.targetViewController = vc
        self.verticalOffset = CGFloat(yOffset)
        self.blurEffect = UIVisualEffectView(frame: self.targetViewController.view.frame)
        self.setupViews()
    }
    
    func show(completion: ((Bool) -> Void)?) {
        self.targetViewController.view.bringSubview(toFront: self.menu)
        self.targetViewController.view.layoutSubviews()
        self.isShowing = true
        
        UIView.animate(withDuration: self.animationDuration,
                       delay: 0,
                       options: UIViewAnimationOptions.curveLinear,
                       animations:
                            { () -> Void in
                                self.menu.center.y = self.verticalOffset + self.menu.bounds.height / 2 + 1
                                self.blurEffect.alpha = 1.0
                            },
                       completion: completion
        )
    }
    
    func hide(completion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: self.animationDuration,
                       delay: 0,
                       options: UIViewAnimationOptions.curveLinear,
                       animations:
                            { () -> Void in
                                self.menu.center.y = self.verticalOffset - self.menu.bounds.height / 2
                                self.blurEffect.alpha = 0.0
                            },
                       completion:
                            { success in
                                self.targetViewController.view.sendSubview(toBack: self.menu)
                                self.targetViewController.view.layoutSubviews()
                                self.isShowing = false
                                completion?(success)
                            }
        )
    }
    
    private func setupViews() {
        self.targetViewController.view.addSubview(self.menu)
        self.targetViewController.view.addConstraintsWithFormat(format: "H:|[v0]|", views: self.menu)
        self.targetViewController.view.addConstraintsWithFormat(format: "V:|-(\(self.verticalOffset - self.menu.bounds.height - 50))-[v0(440)]", views: self.menu)
        
        self.blurEffect.effect = UIBlurEffect(style: .dark)
        self.targetViewController.view.addSubview(self.blurEffect)
        self.blurEffect.alpha = 0.0
        self.targetViewController.view.addConstraintsWithFormat(format: "H:|[v0]|", views: self.blurEffect)
        self.targetViewController.view.addConstraintsWithFormat(format: "V:|[v0]|", views: self.blurEffect)
    }
}
