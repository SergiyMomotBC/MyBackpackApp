//
//  PickerToolbar.swift
//  My Backpack
//
//  Created by Sergiy Momot on 5/5/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

class PickerToolbar: UIToolbar 
{
    weak var pickerView: IQDropDownTextField?
    
    init(for picker: IQDropDownTextField?) {
        self.pickerView = picker
        
        super.init(frame: CGRect.zero)
        
        barStyle = .default
        barTintColor = .darkGray
        isTranslucent = true
        tintColor = UIColor(red: 1.0, green: 1.0, blue: 102/255.0, alpha: 1.0)
        sizeToFit() 
        isUserInteractionEnabled = true
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePicker))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        setItems([space, doneButton, space], animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func donePicker() {
        pickerView?.endEditing(true)
    }
}
