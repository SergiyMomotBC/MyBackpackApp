//
//  NavigationTabBar.swift
//  My Backpack
//
//  Created by Sergiy Momot on 2/17/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

class NavigationTabBar: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    static let height = 44.0
    
    let targetVC: PageViewController
    let tabMenu: UICollectionView
    let tabImageNames = ["content", "calendar", "settings"]
    
    init(frame: CGRect, forViewController vc: PageViewController) {
        self.targetVC = vc
        self.tabMenu = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        super.init(frame: frame)
        
        vc.view.addSubview(self)
        self.backgroundColor = vc.navigationController?.navigationBar.barTintColor ?? UIColor.white
        vc.view.addConstraintsWithFormat(format: "H:|[v0]|", views: self)
        vc.view.addConstraintsWithFormat(format: "V:|[v0(\(NavigationTabBar.height))]", views: self)
        
        if let navigationBar = vc.navigationController?.navigationBar {
            navigationBar.shadowImage = UIImage()
            navigationBar.setBackgroundImage(UIImage(), for: .default)
        }
        
        self.addSubview(tabMenu)
        self.addConstraintsWithFormat(format: "H:|-80-[v0]-80-|", views: self.tabMenu)
        self.addConstraintsWithFormat(format: "V:|[v0]|", views: self.tabMenu)
        self.tabMenu.backgroundColor = self.backgroundColor
        
        self.tabMenu.dataSource = self
        self.tabMenu.delegate = self
        
        self.tabMenu.register(TabBarCell.self, forCellWithReuseIdentifier: "tabButtonCell")
        
        let bottomLineView = UIView()
        bottomLineView.backgroundColor = UIColor.white
        self.addSubview(bottomLineView)
        self.addConstraintsWithFormat(format: "H:|[v0]|", views: bottomLineView)
        self.addConstraintsWithFormat(format: "V:[v0(0.5)]|", views: bottomLineView)
        
        self.layer.zPosition = CGFloat.greatestFiniteMagnitude - 2.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func selectTab(atIndex index: Int) {
        guard index >= 0 && index < self.tabImageNames.count else {
            return
        }
        
        self.tabMenu.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.targetVC.menuController.isShowing {
            self.targetVC.hideMenu()
        }
        
        self.targetVC.setViewControllers(
            [targetVC.orderedViewControllers[indexPath.item]],
            direction: indexPath.item > targetVC.currentPageIndex ? .forward : .reverse,
            animated: true,
            completion: { success in
                if success {
                    self.targetVC.currentPageIndex = indexPath.item
                }
            }
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabImageNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.tabMenu.dequeueReusableCell(withReuseIdentifier: "tabButtonCell", for: indexPath) as! TabBarCell
        cell.setImages(normal: tabImageNames[indexPath.item], highlighted: tabImageNames[indexPath.item] + "_h", withColor: self.targetVC.navigationController?.navigationBar.tintColor)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Double(self.tabMenu.frame.width / CGFloat(tabImageNames.count)), height: NavigationTabBar.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
