//
//  TabBarController.swift
//  GymMe
//
//  Created by Eno Reyes on 7/7/17.
//  Copyright © 2017 Eno Reyes. All rights reserved.
//

import UIKit
import Material

class TabBarController: PageTabBarController {
    open override func prepare() {
        super.prepare()
        
        delegate = self
        preparePageTabBar()
        
        Motion.delay(3) { [weak self] in
            self?.selectedIndex = 2
        }
    }
}

extension TabBarController {
    fileprivate func preparePageTabBar() {
        pageTabBar.lineColor = Color.blueGrey.base
        pageTabBar.dividerColor = Color.blueGrey.lighten5
    }
}

extension TabBarController: PageTabBarControllerDelegate {
    func pageTabBarController(pageTabBarController: PageTabBarController, didTransitionTo viewController: UIViewController) {
        print("pageTabBarController", pageTabBarController, "didTransitionTo viewController:", viewController)
    }
}
