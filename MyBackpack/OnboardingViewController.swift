//
//  ViewController.swift
//  Onboarding
//
//  Created by Sergiy Momot on 4/23/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

class OnboardingViewController: UIPageViewController
{
    fileprivate static let pagesCount = 6
    
    fileprivate lazy var pages: [UIViewController] = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var pages: [UIViewController] = []
        var pageNumber = 0
        
        while pageNumber < OnboardingViewController.pagesCount {
            let page = storyboard.instantiateViewController(withIdentifier: "page\(pageNumber)")
            page.view.backgroundColor = .clear
            pages.append(page)
            pageNumber += 1
        }
        
        return pages
    }()
    
    fileprivate lazy var pageIndicator: UIPageControl = {
        let pageControl = UIPageControl(frame: CGRect(x: 0.0, y: self.view.frame.height - 60.0, width: self.view.frame.width, height: 50.0))
        
        pageControl.numberOfPages = self.pages.count
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.white
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        return pageControl
    }()
    
    fileprivate lazy var advanceButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Skip", for: .normal)
        button.setTitleColor(.yellow, for: .normal)
        button.setTitleColor(.lightGray, for: .highlighted)
        button.addTarget(self, action: #selector(advance), for: .touchUpInside)
        button.frame = CGRect(x: self.view.frame.width - 120.0, y: self.view.frame.height - 57.0, width: 120.0, height: 40.0)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 0.4, green: 0.0, blue: 0.25, alpha: 1.0)
        self.dataSource = self
        self.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.addSubview(pageIndicator)
        self.view.addSubview(advanceButton)
        
        if let firstPage = pages.first {
            self.setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
            self.pageIndicator.currentPage = 0
        }
    }
    
    @objc private func advance() {
        guard let window = UIApplication.shared.keyWindow else { return }
        
        UserDefaults.standard.set(true, forKey: AppDelegate.firstLaunchKey)
        
        let root = self.storyboard!.instantiateViewController(withIdentifier: "root")
        
        UIView.transition(with: window, duration: 0.4, options: .transitionFlipFromLeft, animations: { 
            window.rootViewController = root
        }, completion: nil)
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate
{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let pageIndex = self.pages.index(of: viewController) {
            if pageIndex == 0 {
                return nil
            } else {
                return pages[pageIndex - 1]
            }
        } else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let pageIndex = self.pages.index(of: viewController) {
            if pageIndex == pages.count - 1 {
                return nil
            } else {
                return pages[pageIndex + 1]
            }
        } else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let pageIndex = self.pages.index(of: self.viewControllers!.first!) {
            self.pageIndicator.currentPage = pageIndex
            
            self.advanceButton.setTitle(pageIndex == self.pages.count - 1 ? "Start" : "Skip", for: .normal)
        }
    }
}

