//
//  ContentProvider.swift
//  My Backpack
//
//  Created by Sergiy Momot on 2/24/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

protocol ContentProvider
{
    func presentAnimated(inScrollDirection direction: UIPageViewControllerNavigationDirection)
    var providedContentType: ContentType { get }
    var resource: AnyObject? { get }
    weak var parentVC: NewContentViewController? { get set }
}
