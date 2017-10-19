//
//  WalkthroughContentViewController.swift
//  GymMe
//
//  Created by Eno Reyes on 8/15/17.
//  Copyright © 2017 Eno Reyes. All rights reserved.
//

import UIKit

class WalkthroughContentViewController: UIViewController {

    @IBOutlet weak var backgroundImg: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var forwardButton: UIButton!
    
    var index = 0
    var imageFileName = ""
    var content = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentLabel.text = content
        backgroundImg.image = UIImage(named: imageFileName)
        
        pageControl.currentPage = index
        
        switch index {
        case 0...1:
            forwardButton.setImage(UIImage(named: "arrow.png"), for: .normal)
        case 2:
            forwardButton.setImage(UIImage(named: "doneIcon.png"), for: .normal)
        default:
            break
            
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextBtn_TouchUpInside(_ sender: Any) {
        
        switch index {
        case 0...1:
            let pageVC = parent as! WalkthroughViewController
            pageVC.forward(index: index)
        case 2:
            
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "hasViewedWalkthrough")
            
            dismiss(animated: true, completion: nil)
        default:
            break
            
        }
        
    }

}
