//
//  ContentType.swift
//   
//
//  Created by Sergiy Momot on 2/24/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

enum ContentType: Int {
    case Picture
    case Video
    case Note
    case Audio
    
    var name: String {
        switch self {
        case .Picture:
            return "Picture"
        case .Video:
            return "Video"
        case .Note:
            return "Text Note"
        case .Audio:
            return "Voice Recording"
        }
    }
}
