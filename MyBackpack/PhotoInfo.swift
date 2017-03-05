//
//  PhotoInfo.swift
//  My Backpack
//
//  Created by Sergiy Momot on 3/4/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import Foundation
import NYTPhotoViewer

class PhotoInfo: NSObject, NYTPhoto {
    var image: UIImage?
    var imageData: Data?
    var placeholderImage: UIImage?
    let attributedCaptionTitle: NSAttributedString? = nil
    let attributedCaptionSummary: NSAttributedString? = nil
    let attributedCaptionCredit: NSAttributedString? = nil
    
    init(image: UIImage) {
        self.image = image
    }
}
