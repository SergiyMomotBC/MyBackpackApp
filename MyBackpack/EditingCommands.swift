//
//  EditingCommands.swift
//  Text editor
//
//  Created by Sergiy Momot on 6/9/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

enum EditingAction: Int
{
    case bold
    case italic
    case underline
    case superscript
    case asubscript
    case increaseFont
    case decreaseFont
    case alignLeft
    case alignCenter
    case alignRight
}

fileprivate enum FontStyleOption
{
    case bold
    case italic
    case underline
}

class EditingCommands
{
    let textView: UITextView
    
    init(forTextView textView: UITextView) {
        self.textView = textView
    }
    
    func performCommand(_ command: EditingAction) {
        switch command {
        case .superscript:
            scriptAction(superscript: true)
        case .asubscript:
            scriptAction(superscript: false)
        case .bold:
            fontStyleAction(.bold)
        case .italic:
            fontStyleAction(.italic)
        case .underline:
            fontStyleAction(.underline)
        case .increaseFont:
            fontSizeAction(by: +2)
        case .decreaseFont:
            fontSizeAction(by: -2)
        case .alignLeft:
            alignmentAction(.left)
        case .alignCenter:
            alignmentAction(.center)
        case .alignRight:
            alignmentAction(.right)
        }

    }
    
    fileprivate func fontStyleAction(_ action: FontStyleOption) {
        switch action
        {
        case .underline:
            var newStyle = NSUnderlineStyle.styleSingle.rawValue
            if let underlineStyle = currentValue(for: NSUnderlineStyleAttributeName) as? Int {
                newStyle = underlineStyle == NSUnderlineStyle.styleNone.rawValue ? NSUnderlineStyle.styleSingle.rawValue : NSUnderlineStyle.styleNone.rawValue
            }
            
            applyAttribute(withKey: NSUnderlineStyleAttributeName, value: newStyle)
            
        case .bold, .italic:
            let currentFont = currentValue(for: NSFontAttributeName) as! UIFont
            
            var isBold = currentFont.fontName.contains("Bold")
            var isItalic = currentFont.fontName.contains("Italic")
            
            if action == .bold {
                isBold = !isBold
            } else {
                isItalic = !isItalic
            }
            
            let indexOfDash = currentFont.fontName.characters.index(of: "-")!
            let fontFamilyName = currentFont.fontName.substring(to: indexOfDash)
            
            let finalName = fontFamilyName + "-" + (isBold ? "Bold" : "") + (isItalic ? "Italic" : "") + (!isBold && !isItalic ? "Regular" : "")
            let newFont = UIFont(name: finalName, size: currentFont.pointSize)!
            
            applyAttribute(withKey: NSFontAttributeName, value: newFont)
        }
    }

    fileprivate func scriptAction(superscript: Bool) {
        let currentFont = currentValue(for: NSFontAttributeName) as! UIFont
        let currentBaseline = currentValue(for: NSBaselineOffsetAttributeName) as? NSNumber ?? 0.0
        
        if currentBaseline == 0.0 {
            applyAttribute(withKey: NSFontAttributeName, value: currentFont.withSize(currentFont.pointSize / 2 + 2))
            applyAttribute(withKey: NSBaselineOffsetAttributeName, value: currentFont.pointSize / 2 * (superscript ? 1 : -1) + (superscript ? -2 : 4))
        } else {
            applyAttribute(withKey: NSFontAttributeName, value: currentFont.withSize((currentFont.pointSize - 2) * 2))
            applyAttribute(withKey: NSBaselineOffsetAttributeName, value: 0)
        }
    }
    
    fileprivate func fontSizeAction(by delta: Int) {
        let currentFont = currentValue(for: NSFontAttributeName) as! UIFont
        let newFontSize = max(min(currentFont.pointSize + CGFloat(delta), 48), 8)
        applyAttribute(withKey: NSFontAttributeName, value: currentFont.withSize(newFontSize))
    }
    
    fileprivate func alignmentAction(_ alignment: NSTextAlignment) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        applyAttribute(withKey: NSParagraphStyleAttributeName, value: paragraphStyle)
    }
    
    private func currentValue(for attribute: String) -> Any? {
        if textView.selectedRange.length > 0 {
            return textView.attributedText.attribute(attribute, at: textView.selectedRange.location, effectiveRange: nil)
        } else {
            return textView.typingAttributes[attribute]
        }
    }
    
    private func applyAttribute(withKey key: String, value: Any) {
        if textView.selectedRange.length > 0 {
            let range = textView.selectedRange
            let mutableString = NSMutableAttributedString(attributedString: textView.attributedText)
            mutableString.addAttribute(key, value: value, range: range)
            textView.attributedText = mutableString
            textView.selectedRange = range
        } else {
            textView.typingAttributes[key] = value
        }
    }
}
