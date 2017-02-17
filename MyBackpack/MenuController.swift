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
    
    let menu: UIStackView!
    let targetViewController: UIViewController!
    let blurEffect: UIVisualEffectView
    
    init(withStackView stackView: UIStackView, inViewController vc: UIViewController, withYOffset yOffset: Double) {
        self.menu = stackView
        self.targetViewController = vc
        self.verticalOffset = CGFloat(yOffset)
        
        self.blurEffect = UIVisualEffectView(frame: self.targetViewController.view.frame)
        self.setupBlurEffect()
        
        self.setupMenu()
    }
    
    func show(completion: @escaping (Bool) -> Void) {
        UIView.animate(withDuration: self.animationDuration,
                       delay: 0,
                       options: UIViewAnimationOptions.curveLinear,
                       animations:
                            { () -> Void in
                                self.menu.center.y = self.verticalOffset + self.menu.bounds.height / 2 + 1
                                self.blurEffect.alpha = 1.0
                            },
                       completion: completion)
        
        self.isShowing = true
    }
    
    func hide(completion: @escaping (Bool) -> Void) {
        UIView.animate(withDuration: self.animationDuration,
                       delay: 0,
                       options: UIViewAnimationOptions.curveLinear,
                       animations:
                            { () -> Void in
                                self.menu.center.y = self.verticalOffset - self.menu.bounds.height / 2
                                self.blurEffect.alpha = 0.0
                            },
                       completion: completion)
        
        self.isShowing = false
    }
    
    private func setupMenu() {
        self.targetViewController.view.addSubview(self.menu)
        self.menu.center.y =  self.verticalOffset - self.menu.bounds.height / 2
        
        let viewsDictionary = ["stackView": self.menu]
        
        let stackView_H = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[stackView]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: viewsDictionary)
        
        let stackView_V = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-0-[stackView(300)]|",
            options: NSLayoutFormatOptions(rawValue:0),
            metrics: nil,
            views: viewsDictionary)
        
        self.targetViewController.view.addConstraints(stackView_V)
        self.targetViewController.view.addConstraints(stackView_H)
    }
    
    private func setupBlurEffect() {
        self.blurEffect.effect = UIBlurEffect(style: .light)
        self.targetViewController.view.addSubview(self.blurEffect)
        self.blurEffect.alpha = 0.0
        let viewsDictionary = ["blurEffect": self.blurEffect]
        
        let horizontal = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[blurEffect]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: viewsDictionary)
        
        let vertical = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-0-[blurEffect]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: viewsDictionary)
        
        self.targetViewController.view.addConstraints(horizontal)
        self.targetViewController.view.addConstraints(vertical)
    }
}
