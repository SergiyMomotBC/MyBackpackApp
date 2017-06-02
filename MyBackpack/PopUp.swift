//
//  PopUp.swift
//  My Backpack
//
//  Created by Sergiy Momot on 5/5/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import SCLAlertView

class PopUp: SCLAlertView {
    required init() {
        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: CGFloat(UIScreen.main.bounds.size.width - 40),
            kTextHeight: 50,
            kButtonHeight: 50.0,
            kTitleFont: UIFont(name: "Avenir Next", size: 18)!,
            kTextFont: UIFont(name: "Avenir Next", size: 14)!,
            kButtonFont: UIFont(name: "Avenir Next", size: 15)!
        )  
        
        super.init(appearance: appearance)
    }
    
    func displayEdit(title: String) {
        showEdit(title, subTitle: "", closeButtonTitle: "Cancel", duration: 0.0, colorStyle: 0x800040, colorTextButton: 0xFFFFFF, circleIconImage: nil, animationStyle: .topToBottom)
    }
    
    func displayInfo(title: String) {
        showInfo(title, subTitle: "", closeButtonTitle: "Close", duration: 0.0, colorStyle: 0x800040, colorTextButton: 0xFFFFFF, circleIconImage: nil, animationStyle: .topToBottom)
    }    
    
    func displayError(message: String, closeButtonTitle: String = "OK") {
        showError(closeButtonTitle == "OK" ? "Error" : "Access denied", subTitle: message, closeButtonTitle: closeButtonTitle, duration: 0.0, colorStyle: 0x800040, colorTextButton: 0xFFFFFF, circleIconImage: nil, animationStyle: .topToBottom)
    }
    
    func displayWarning(message: String) {
        showWarning("Warning", subTitle: message, closeButtonTitle: "Cancel", duration: 0.0, colorStyle: 0x800040, colorTextButton: 0xFFFFFF, circleIconImage: nil, animationStyle: .topToBottom)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
