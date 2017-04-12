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
        
        let backgroundColorView = UIView()
        backgroundColorView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        self.selectedBackgroundView = backgroundColorView
        
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
            setImageThumbnail(fromPath: content.resourceURL!)
            self.contentTypeLabel.text = "Picture"
            
        case .Video:
            setImageThumbnail(fromPath: content.resourceURL!)
                        
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: contentPreview.frame.width, height: contentPreview.frame.height))
            imageView.contentMode = .center
            imageView.tag = 1
            imageView.image = UIImage(named: "videoPlayButton")?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
            self.contentPreview.addSubview(imageView)
            
            self.contentTypeLabel.text = "Video"
        }
    }
    
    override func prepareForReuse() {
        self.contentPreview.viewWithTag(1)?.removeFromSuperview()
        self.contentPreview.image = nil
    }
    
    private func setImageThumbnail(fromPath pathString: String) {
        var path = pathString

        if let pointIndex = path.characters.index(of: ".") {
            path.insert(contentsOf: "_t".characters, at: pointIndex)
            
            path = path.replacingOccurrences(of: ".mov", with: ".jpeg")
            
            self.contentPreview.image = UIImage(contentsOfFile: ContentFileManager.shared.documentsFolderURL.appendingPathComponent(path).path)
        }
    }
}
