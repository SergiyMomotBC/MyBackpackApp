//
//  ContentTableViewCell.swift
//  My Backpack
//
//  Created by Sergiy Momot on 2/20/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

class ContentTableViewCell: UITableViewCell
{
    @IBOutlet weak var contentPreview: UIImageView!
    @IBOutlet weak var contentTypeLabel: UILabel!
    @IBOutlet weak var contentTimeDateLabel: UILabel!
    @IBOutlet weak var contentTitleLabel: UILabel!

    func prepareCell(forType type: ContentType) {
        self.contentView.subviews.first?.layer.cornerRadius = 8
        
        switch type {
        case .Audio:
            self.contentPreview.image = UIImage(named: "recordingContent")?.withRenderingMode(.alwaysTemplate)
            self.contentPreview.tintColor = .white
            self.contentPreview.contentMode = .center
            
        case .Note:
            self.contentPreview.image = UIImage(named: "documentContent")?.withRenderingMode(.alwaysTemplate)
            self.contentPreview.contentMode = .center
            self.contentPreview.tintColor = .white
            
        case .Picture:
            self.contentPreview.image = UIImage(named: "test")
            
        case .Video:
            self.contentPreview.image = UIImage(named: "test")
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: contentPreview.frame.width, height: contentPreview.frame.height))
            imageView.contentMode = .center
            imageView.tag = 1
            imageView.image = UIImage(named: "videoPlayButton")?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
            self.contentPreview.addSubview(imageView)
        }
    }
    
    override func prepareForReuse() {
        self.contentPreview.viewWithTag(1)?.removeFromSuperview()
    }
}
