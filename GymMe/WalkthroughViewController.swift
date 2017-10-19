//
//  WalkthroughViewController.swift
//  GymMe
//
//  Created by Eno Reyes on 8/15/17.
//  Copyright © 2017 Eno Reyes. All rights reserved.
//

import UIKit

class WalkthroughViewController: UIPageViewController, UIPageViewControllerDataSource {

    var pageContent = ["This is the first page.",
                       "This is the second page.",
                       "This is the third page."]
    
    var pageImage = ["background1", "background2", "background3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        // Do any additional setup after loading the view.
        if let startingVC = viewControllerAtIndex(index: 0) {
            setViewControllers([startingVC], direction: .forward, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentViewController).index
        
        index += 1
        return viewControllerAtIndex(index: index)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentViewController).index
        
        index -= 1
        return viewControllerAtIndex(index: index)
    }
    
    func viewControllerAtIndex(index: Int) -> WalkthroughContentViewController? {
        if index < 0 || index >= pageContent.count {
            return nil
        }
        
        if let pageContentVC = storyboard?.instantiateViewController(withIdentifier: "WalkthroughContentViewController") as? WalkthroughContentViewController {
            pageContentVC.content = pageContent[index]
            pageContentVC.index = index
            pageContentVC.imageFileName = pageImage[index]
            return pageContentVC
        }
        
        return nil
    }
    
    func forward(index: Int) {
        if let nextVC = viewControllerAtIndex(index: index + 1) {
        setViewControllers([nextVC], direction: .forward, animated: true, completion: nil)
        }
    }
}
