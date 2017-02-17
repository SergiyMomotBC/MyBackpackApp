//
//  UIViewExtentions.swift
//  My Backpack
//
//  Created by Sergiy Momot on 2/17/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

extension UIView
{
    func addConstraintsWithFormat(format: String, views: UIView...) {
        
        var viewDictionary = [String: UIView]()
        
        for(index, view) in views.enumerated(){
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewDictionary))
    }
}
