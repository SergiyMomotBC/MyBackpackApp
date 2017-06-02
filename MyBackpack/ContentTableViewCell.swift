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
    @IBOutlet weak var contentInfoLabel: UILabel!
    @IBOutlet weak var contentTitleLabel: UILabel!

    func prepareCell(forContent content: Content) {
        self.contentView.subviews.first?.layer.cornerRadius = 8
        self.contentPreview.tintColor = .white
        
        let backgroundColorView = UIView()
        backgroundColorView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        self.selectedBackgroundView = backgroundColorView
        
        let type = ContentType(rawValue: Int(content.typeID))!
        
        self.contentTitleLabel.text = content.title
        
        var typeString = ""
        
        switch type {
        case .Audio:
            self.contentPreview.image = UIImage(named: "recordingContent")?.withRenderingMode(.alwaysTemplate)
            self.contentPreview.contentMode = .center
            typeString = "Audio"
            
        case .Note:
            self.contentPreview.image = UIImage(named: "documentContent")?.withRenderingMode(.alwaysTemplate)
            self.contentPreview.contentMode = .center
            typeString = "Text Note"
            
        case .Picture:
            setImageThumbnail(fromPath: content.resourceURL)
            typeString = "Picture"
            
        case .Video:
            setImageThumbnail(fromPath: content.resourceURL)
                        
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: contentPreview.frame.width, height: contentPreview.frame.height))
            imageView.contentMode = .center
            imageView.tag = 1
            imageView.image = UIImage(named: "videoPlayButton")?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
            self.contentPreview.addSubview(imageView)
            
            typeString = "Video"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy  h:mm a"
        let dateString = dateFormatter.string(from: content.dateCreated as Date)
        
        let size = content.fileSize
        var sizeString = ""
        
        if size > 1024 * 1024 {
            sizeString = String(format: "%.2f MB", Double(size) / (1024.0 * 1024.0))
        } else if size > 1024 {
            sizeString = String(format: "%.2f kB", Double(size) / 1024.0)
        } else {
            sizeString = "\(size) B"
        }
        
        self.contentInfoLabel.text = "   " + typeString + " ● " + dateString + " ● " + sizeString
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
