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

    func prepareCell(forContent content: Content) {
        self.contentView.subviews.first?.layer.cornerRadius = 8
        self.contentPreview.tintColor = .white
        
        let type = ContentType(rawValue: Int(content.typeID))!
        
        self.contentTitleLabel.text = content.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a   MM/dd/yyyy"
        self.contentTimeDateLabel.text = dateFormatter.string(from: content.dateCreated! as Date)
        
        switch type {
        case .Audio:
            self.contentPreview.image = UIImage(named: "recordingContent")?.withRenderingMode(.alwaysTemplate)
            self.contentPreview.contentMode = .center
            self.contentTypeLabel.text = "Audio"
            
        case .Note:
            self.contentPreview.image = UIImage(named: "documentContent")?.withRenderingMode(.alwaysTemplate)
            self.contentPreview.contentMode = .center
            self.contentTypeLabel.text = "Text Note"
            
        case .Picture:
            self.contentPreview.image = UIImage(contentsOfFile: ContentFileManager.shared.documentsFolderURL.appendingPathComponent(content.resourceURL!).path)
            self.contentTypeLabel.text = "Picture"
            
        case .Video:
            self.contentPreview.image = UIImage(named: "test")
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: contentPreview.frame.width, height: contentPreview.frame.height))
            imageView.contentMode = .center
            imageView.tag = 1
            imageView.image = UIImage(named: "videoPlayButton")?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
            self.contentPreview.addSubview(imageView)
            
            self.contentTitleLabel.text = "Video"
        }
    }
    
    override func prepareForReuse() {
        self.contentPreview.viewWithTag(1)?.removeFromSuperview()
        self.contentPreview.image = nil
    }
}
