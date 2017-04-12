//
//  ContentFileManager.swift
//  My Backpack
//
//  Created by Sergiy Momot on 3/3/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import AVFoundation

fileprivate enum IDParameter: String {
    case nextPictureID
    case nextVideoID
    case nextAudioID
    case nextNoteID
}

class ContentFileManager
{
    public static let shared: ContentFileManager = ContentFileManager()
    
    let documentsFolderURL: URL
    
    private init() {
        self.documentsFolderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func saveResource(_ resource: AnyObject, ofType type: ContentType) -> String? {
        let prefix = type.name.lowercased() + "_"
        
        switch type {
        case .Audio:
            return self.saveAudio(url: resource as! URL, filename: prefix + String(UserDefaults.standard.integer(forKey: IDParameter.nextAudioID.rawValue)))
        case .Note:
            return self.saveNote(text: resource as! String, filename: prefix + String(UserDefaults.standard.integer(forKey: IDParameter.nextNoteID.rawValue)))
        case .Picture:
            return self.savePicture(image: resource as! UIImage, filename: prefix + String(UserDefaults.standard.integer(forKey: IDParameter.nextPictureID.rawValue)))
        case .Video:
            return self.saveVideo(url: resource as! URL, filename: prefix + String(UserDefaults.standard.integer(forKey: IDParameter.nextVideoID.rawValue)))
        }
    }
    
    private func saveNote(text: String, filename: String) -> String? {
        let data = text.data(using: String.Encoding.unicode)
        let path = documentsFolderURL.appendingPathComponent(filename + ".html")
        
        do {
            try data?.write(to: path, options: .atomic)
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: IDParameter.nextNoteID.rawValue) + 1, forKey: IDParameter.nextNoteID.rawValue)
            return filename + ".html"
        } catch {
            print("HTML text could not be written to documents directory...")
            return nil
        }
    }
    
    private func savePicture(image: UIImage, filename: String) -> String? {
        let data = UIImageJPEGRepresentation(image, 1.0)
        let path = documentsFolderURL.appendingPathComponent(filename + ".jpeg")
        let dataThumbnail = UIImageJPEGRepresentation(generateImageThumbnail(ofPicture: image), 1.0)
        let pathThumbnail = documentsFolderURL.appendingPathComponent(filename + "_t.jpeg")
        
        do {
            try data?.write(to: path, options: .atomic)
            try dataThumbnail?.write(to: pathThumbnail, options: .atomic)
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: IDParameter.nextPictureID.rawValue) + 1, forKey: IDParameter.nextPictureID.rawValue)
            return filename + ".jpeg"
        } catch {
            print("Image could not be written to documents directory...")
            return nil
        }
    }
    
    private func saveVideo(url: URL, filename: String) -> String? {
        let path = documentsFolderURL.appendingPathComponent(filename + ".mov")
        
        if let thumbnail = generateVideoThumbnail(fromURL: url) {
            let data = UIImageJPEGRepresentation(thumbnail, 1.0)
            let path = documentsFolderURL.appendingPathComponent(filename + "_t.jpeg")
            
            try? data?.write(to: path, options: .atomic)
        }
        
        if moveToDocuments(from: url, to: path) {
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: IDParameter.nextVideoID.rawValue) + 1, forKey: IDParameter.nextVideoID.rawValue)
            return filename + ".mov"
        } else {
            return nil
        }
    }
    
    private func saveAudio(url: URL, filename: String) -> String? {
        let path = documentsFolderURL.appendingPathComponent(filename + ".m4a")
        if moveToDocuments(from: url, to: path) {
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: IDParameter.nextAudioID.rawValue) + 1, forKey: IDParameter.nextAudioID.rawValue)
            return filename + ".m4a"
        } else {
            return nil
        }
    }
    
    private func moveToDocuments(from source: URL, to destination: URL) -> Bool {
        do {
            try FileManager.default.moveItem(at: source, to: destination)
            return true
        } catch {
            print("File could not be moved to documents folder...")
            return false
        }
    }
    
    private func generateVideoThumbnail(fromURL url: URL) -> UIImage? {
        let imageGenerator = AVAssetImageGenerator(asset: AVURLAsset(url: url))
        imageGenerator.appliesPreferredTrackTransform = true
        
        if let cgImage = try? imageGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil) {
            return UIImage(cgImage: cgImage)
        } else {
            return nil
        }
    }
    
    private func generateImageThumbnail(ofPicture image: UIImage) -> UIImage {
        let finalSize: CGFloat = 128.0
        let scale = max(finalSize / image.size.width, finalSize / image.size.height)
        let width = image.size.width * scale
        let height = image.size.height * scale
        let imageRect = CGRect(x: (finalSize - width) / 2.0, y: (finalSize - height) / 2.0, width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: finalSize, height: finalSize), false, 0)
        image.draw(in: imageRect)
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return thumbnail!
    }
}
