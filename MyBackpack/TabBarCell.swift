//
//  TabBarCell.swift
//  My Backpack
//
//  Created by Sergiy Momot on 2/17/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

class TabBarCell: UICollectionViewCell
{
    let imageView: UIImageView
    let selectorView: UIView
    
    var normalImage: UIImage?
    var highlightedImage: UIImage?
    
    override init(frame: CGRect) {
        self.imageView = UIImageView(image: nil)
        self.selectorView = UIView()
        
        super.init(frame: frame)
        
        self.addSubview(imageView)
        self.addConstraintsWithFormat(format: "H:|-5-[v0]-5-|", views: self.imageView)
        self.addConstraintsWithFormat(format: "V:|[v0]-10-|", views: self.imageView)
        self.imageView.contentMode = .scaleAspectFit
        
        self.addSubview(selectorView)
        self.selectorView.isHidden = true
        self.addConstraintsWithFormat(format: "H:|[v0]|", views: self.selectorView)
        self.addConstraintsWithFormat(format: "V:[v0(3)]|", views: self.selectorView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImages(normal normalImageName: String, highlighted highlightedImageName: String, withColor color: UIColor?) {
        self.normalImage = UIImage(named: normalImageName)?.withRenderingMode(.alwaysTemplate)
        self.highlightedImage = UIImage(named: highlightedImageName)?.withRenderingMode(.alwaysTemplate)
        self.imageView.image = self.normalImage
        self.imageView.tintColor = color ?? UIColor.black
        self.selectorView.backgroundColor = color ?? UIColor.black
    }
    
    override var isSelected: Bool {
        didSet {
            self.imageView.image = isSelected ? self.highlightedImage : self.normalImage
            self.selectorView.isHidden = !isSelected
        }
    }
}

