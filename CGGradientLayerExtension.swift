//
//  CGGradientLayerExtension.swift
//  My Backpack
//
//  Created by Sergiy Momot on 2/18/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import QuartzCore
import UIKit

extension CAGradientLayer {
    class func gradientLayer(forBounds bounds: CGRect, startColor: UIColor, endColor: UIColor) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame = bounds
        layer.colors = [startColor.cgColor, endColor.cgColor]
        return layer
    }
}
