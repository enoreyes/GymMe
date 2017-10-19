//
//  FilterViewController.swift
//  GymMe
//
//  Created by Eno Reyes on 8/8/17.
//  Copyright © 2017 Eno Reyes. All rights reserved.
//

import UIKit

protocol FilterViewControllerDelegate {
    func updatePhoto(image: UIImage)
}

class FilterViewController: UIViewController {

    @IBOutlet weak var filterPhoto: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var delegate: FilterViewControllerDelegate?
    var selectedImage: UIImage!
    var CIFilterNames = [
        "Default",
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectMono",
        "CIPhotoEffectNoir",
        "CIPhotoEffectProcess",
        "CIPhotoEffectTonal",
        "CIPhotoEffectTransfer",
        "CISepiaTone"
    ]
    
    var viewableFilterNames = [
        "No Filter",
        "Chrome",
        "Faded",
        "Instant",
        "Mono",
        "Noir",
        "Process",
        "Tonal",
        "Transfer",
        "Sepia"
    ]
    
    var context = CIContext(options: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterPhoto.image = selectedImage

        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelButtonTouchUpInside(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextButtonTouchUpInside(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.updatePhoto(image: self.filterPhoto.image!)
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

extension FilterViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CIFilterNames.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as! FilterCollectionViewCell
        let context = CIContext(options: nil)
        let newImage = resizeImage(image: selectedImage, newWidth: 150)
        let ciImage = CIImage(image: newImage)
        
        if indexPath.item > 0 {
        
        let filter = CIFilter(name: CIFilterNames[indexPath.item])
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        if let filteredImage = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
            let result = context.createCGImage(filteredImage, from: filteredImage.extent)
            cell.filterPhoto.image = UIImage(cgImage: result!)
            
        }
            
        } else {
            cell.filterPhoto.image = newImage
        }
        
        cell.filterName.text = viewableFilterNames[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let context = CIContext(options: nil)
        let ciImage = CIImage(image: selectedImage)
        
        if indexPath.item > 0 {
        let filter = CIFilter(name: CIFilterNames[indexPath.item])
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        if let filteredImage = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
            let result = context.createCGImage(filteredImage, from: filteredImage.extent)
            let finalImage = UIImage(cgImage: result!, scale: selectedImage.scale, orientation: selectedImage.imageOrientation)
            self.filterPhoto.image = finalImage
        }
        } else {
            self.filterPhoto.image = selectedImage
        }
        
    }
}

