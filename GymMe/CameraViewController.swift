//
//  CameraViewController.swift
//  GymMe
//
//  Created by Eno Reyes on 7/1/17.
//  Copyright © 2017 Eno Reyes. All rights reserved.
//

import UIKit
import AVFoundation
import Fusuma
import GooglePlacePicker

class CameraViewController: UIViewController {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var shareButton: UIButton!
    var selectedImage: UIImage?
    @IBOutlet weak var removeButton: UIBarButtonItem!
    @IBOutlet weak var locationLabel: UILabel!
    
    let placeholderString = "Say something here"
    var videoUrl: URL?
    var isTextPost: Bool?
    var location: GMSPlace?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captionTextView.delegate = self
        captionTextView.text = placeholderString
        captionTextView.textColor = UIColor.lightGray
        let captionTextHeight = captionTextView.frame.height / 2 - 10
        captionTextView.contentInset = UIEdgeInsetsMake(-captionTextHeight,0.0,0,0.0);
        
        self.tabBarController?.tabBar.tintColor = Config.GYM_RED
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: Config.GYM_RED]

        // Check for taps on photo input.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectPhoto))
        photo.addGestureRecognizer(tapGesture)
        photo.isUserInteractionEnabled = true
        locationLabel.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handlePost()
    }
    
    //THIS METHOD MAKES SURE THERE IS A PHOTO IN ORDER TO POST
  
    func handlePost() {
        if selectedImage != nil {
            self.shareButton.isEnabled = true
            self.removeButton.isEnabled = true
            self.shareButton.backgroundColor = UIColor.black
            isTextPost = false
        } else {
            self.shareButton.isEnabled = true
            self.removeButton.isEnabled = false
            self.shareButton.backgroundColor = UIColor.black
            isTextPost = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    //Dismiss keyboard on touch.
    @objc func handleSelectPhoto() {
        
        /*
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.mediaTypes = ["public.image", "public.movie"]
        present(pickerController, animated: true, completion: nil)
        */
        
        let fusuma = FusumaViewController()
        fusuma.delegate = self as? FusumaDelegate
        fusuma.hasVideo = true // If you want to let the users allow to use video.
        fusuma.cropHeightRatio = 1 // Height-to-width ratio. The default value is 1, which means a squared-size photo.
        fusuma.allowMultipleSelection = false // You can select multiple photos from the camera roll. The default value is false.
        fusuma.defaultMode = FusumaMode.camera // The first choice to show (.camera, .library, .video). The default value is .camera.
        self.present(fusuma, animated: true, completion: nil)
    }
    
    @IBAction func shareButtonTouchUpInside(_ sender: Any) {
        
        var lat = 0.0
        var long = 0.0
        var locationName = ""
        
        if location != nil {
            lat = location!.coordinate.latitude
            long = location!.coordinate.longitude
            locationName = location!.name
        }
        
        ProgressHUD.show("Waiting...", interaction: false)
        if let profileImg = self.selectedImage, let imageData = UIImageJPEGRepresentation(profileImg, 0.8) {
            
            let ratio = profileImg.size.width / profileImg.size.height
            
            HelperService.uploadDataToServer(data: imageData, ratio: ratio, videoUrl: self.videoUrl, caption: captionTextView.text!, isTextPost: isTextPost!, lat: lat, long: long, locationName: locationName, onSuccess: {
                self.clean()
                self.tabBarController?.selectedIndex = 0
            })
        } else if isTextPost! {
            let ratio = 1.0 as CGFloat
            let imageData = UIImageJPEGRepresentation(UIImage(named: "textPhoto")!, 0.8)
            
            HelperService.uploadDataToServer(data: imageData!, ratio: ratio, videoUrl: self.videoUrl, caption: captionTextView.text!, isTextPost: true, lat: lat, long: long, locationName: locationName, onSuccess: {
                self.clean()
                self.tabBarController?.selectedIndex = 0
            })

        } else {
            ProgressHUD.showError("Error posting photo.")
        }
    }

    @IBAction func removeTouchUpInside(_ sender: Any) {
        clean()
        handlePost()
    }
    
    func clean() {
        self.captionTextView.text = ""
        self.locationLabel.text = ""
        self.photo.image = UIImage(named: "placeholder-photo")
        self.selectedImage = nil
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Filter_Segue" {
            let filterVC = segue.destination as! FilterViewController
            filterVC.selectedImage = self.selectedImage
            filterVC.delegate = self
        }
    }
    
    @IBAction func addLocationTouchUpInside(_ sender: Any) {
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        
        present(placePicker, animated: true, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.locationLabel.text = ""
        self.location = nil
    }
}

extension CameraViewController: GMSPlacePickerViewControllerDelegate {
    
    // To receive the results from the place picker 'self' will need to conform to
    // GMSPlacePickerViewControllerDelegate and implement this code.
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        location = place
        locationLabel.text = location?.name
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
    }
}

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // This runs after the user finishes picking the photo for their profile.
    
    // MAKE LIMIT FOR VIDEO TIME 60s
    
    /*
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info["UIImagePickerControllerMediaURL"] as? URL {
            if let thumbnailImage = self.thumbnailImageForFileUrl(videoUrl) {
                selectedImage = thumbnailImage
                photo.image = thumbnailImage
                self.videoUrl = videoUrl
            }
            dismiss(animated: true, completion: nil)
        }
        
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImage = image
            photo.image = image
            
            dismiss(animated: true, completion: {
                self.performSegue(withIdentifier: "Filter_Segue", sender: nil)
            })
        }
        
        //dismisses the image picker view
    }
 
     */
    
    func thumbnailImageForFileUrl(_ fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(6,3), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let err {
            print(err)
        }
        
        return nil
    }
}

extension CameraViewController: FilterViewControllerDelegate {
    func updatePhoto(image: UIImage) {
        self.photo.image = image
        self.selectedImage = image
    }
}

extension CameraViewController: FusumaDelegate {
    
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        
        selectedImage = image
        photo.image = image
        
        dismiss(animated: true, completion: {
            self.performSegue(withIdentifier: "Filter_Segue", sender: nil)
        })
    }
    
    func fusumaDismissedWithImage(image: UIImage, source: FusumaMode) -> () {
        
        print("dissmissed")
        
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL)  -> () {
        
        let videoUrl = fileURL as URL
        
        if let thumbnailImage = self.thumbnailImageForFileUrl(videoUrl) {
            selectedImage = thumbnailImage
            photo.image = thumbnailImage
            self.videoUrl = videoUrl
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
        
    }
    
    func fusumaCameraRollUnauthorized() {
        
        ProgressHUD.showError("Camera roll unauthorized")
    }

}

extension CameraViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderString
            textView.textColor = UIColor.lightGray
        }
    }
}
