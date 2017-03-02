//
//  ViewController.swift
//  Test
//
//  Created by Sergiy Momot on 2/28/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var toggle: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.delegate = self
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let str = NSMutableAttributedString(attributedString: textView.attributedText)
        
        if text.isEmpty {
            str.deleteCharacters(in: NSRange(location: str.length-1, length: 1))
            textView.attributedText = str
            return false
        }
        
        str.append(NSAttributedString(string: text))
        if self.toggle.isOn {
            str.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: NSRange(location: textView.attributedText.length, length: text.characters.count))
        } else {
            str.addAttribute(NSForegroundColorAttributeName, value: UIColor.green, range: NSRange(location: textView.attributedText.length, length: text.characters.count))
        }
        
        textView.attributedText = str
        return false
    }
}

