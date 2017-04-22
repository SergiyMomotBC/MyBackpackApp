//
//  Searchable.swift
//  My Backpack
//
//  Created by Sergiy Momot on 4/21/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import Foundation

protocol Searchable
{
    func prepareForSearch(with controller: SearchController)
    func getFilterViewControllerToPresent() -> UIViewController
    func updateSearch(forText text: String)
    func endSearch()
}
