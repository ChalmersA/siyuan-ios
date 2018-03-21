//
//  AskViewController.swift
//  Charging
//
//  Created by xpg on 6/10/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

import UIKit

class AskViewController: DCViewController, KZPhotoBrowserDelegate, UITextViewDelegate {

    @IBOutlet weak var askTextView: DCTextView!
    
    @IBOutlet weak var photo1: UIButton!
    @IBOutlet weak var photo2: UIButton!
    @IBOutlet weak var photo3: UIButton!
    @IBOutlet weak var photo4: UIButton!
    @IBOutlet weak var photo5: UIButton!
    
    var photoButtons: [UIButton]?
    
    var images: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        askTextView.placeholder = "请简要描述你的问题和意见"
        askTextView.layer.cornerRadius = 3
        askTextView.layer.masksToBounds = true
        askTextView.layer.borderWidth = 1;
        askTextView.layer.borderColor = UIColor.paletteButtonBoradColor().CGColor
        askTextView.delegate = self
        
        photoButtons = [photo1, photo2, photo3, photo4, photo5]
        reloadPhotos(images)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        view.window?.endEditing(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Action
    @IBAction func submit(sender: AnyObject) {
        let hud = MBProgressHUD.showHUDAddedTo(navigationController?.view, animated: true)
        if askTextView.text.characters.count == 0 {
            hideHUD(hud, withText: "请简要描述你的问题和意见")
            return
        }
        
        let imagesData = images.map { (image) -> NSData in
            UIImageJPEGRepresentation(image, 1)!
        }
        
        DCSiteApi.postFeedback(askTextView.text, userid: DCApp.sharedApp().user?.userId, images: imagesData) { (task: NSURLSessionDataTask!, success: Bool, response: DCWebResponse!, error: NSError!) -> Void in
            if !success || !response.isSuccess() {
                self.hideHUD(hud, withText: DCWebResponse.errorMessage(error, withResponse: response))
                return
            }
            self.hideHUD(hud, withText: "提交成功")
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func tapPhoto(sender: UIButton) {
        view.endEditing(true)
        if sender.tag < images.count {
            let browser = KZPhotoBrowser(delegate: self)
            browser.setCurrentPhotoIndex(UInt(sender.tag))
            navigationController?.pushViewController(browser, animated: true)
        }
        else if sender.tag == images.count {
            selectImagePickerSource { [unowned self] (source: UIImagePickerControllerSourceType) -> Void in
                if source == .Camera {
                    let cameraVC = DCImagePickerController()
                    cameraVC.sourceType = source
                    self.presentViewController(cameraVC, animated: true, completion: nil)
                    cameraVC.completion = { (image, originalImage) -> Void in
                        if let scaledImage = self.scaleImage(originalImage) {
                            self.images.append(scaledImage)
                            self.reloadPhotos(self.images)
                        }
                    }
                    
                } else {
                    let imagesPicker = PhotoPickerViewController()
                    imagesPicker.status = .CameraRoll
                    if let total = self.photoButtons?.count {
                        imagesPicker.minCount = total - self.images.count
                    }
                    imagesPicker.show()
                    
                    imagesPicker.callBack = { (assets: AnyObject?) -> Void in
                        let images = self.imagesFromAssets(assets)
                        self.images += images
                        self.reloadPhotos(self.images)
                    }
                }
                
            }
        }
    }
    
    // MARK: - KZPhotoBrowserDelegate
    func numberOfPhotosInPhotoBrowser(photoBrowser: KZPhotoBrowser!) -> UInt {
        return UInt(images.count)
    }
    
    func photoBrowser(photoBrowser: KZPhotoBrowser!, photoAtIndex index: UInt) -> KZPhoto! {
        let image = images[Int(index)]
        return KZPhoto(image: image)
    }
    
    func photoBrowser(photoBrowser: KZPhotoBrowser!, deletePhotoAtIndex index: UInt) {
        images.removeAtIndex(Int(index))
        photoBrowser.reloadData()
        reloadPhotos(images)
    }
    
    // MARK: - Extension
    func reloadPhotos(images: NSArray) {
        if let photoButtons = photoButtons {
            for index in 0..<photoButtons.count {
                let photoButton = photoButtons[index]
                photoButton.imageView?.contentMode = .ScaleAspectFill
                if index < images.count {
                    photoButton.hidden = false
                    photoButton.setImage(images[index] as? UIImage, forState: .Normal)
                } else if index == images.count {
                    photoButton.hidden = false
                    photoButton.setImage(UIImage(named: "help_button_add_photo"), forState: .Normal)
                } else {
                    photoButton.hidden = true
                    photoButton.setImage(nil, forState: .Normal)
                }
            }
        }
    }
    
    func imagesFromAssets(assets: AnyObject?) -> [UIImage] {
        var images: [UIImage] = []
        if let mlAssets = assets as? [MLSelectPhotoAssets] {
            for mlAsset in mlAssets {
                autoreleasepool {
                    let assetRepresentation = mlAsset.asset.defaultRepresentation()
                    let orientation = UIImageOrientation(rawValue: assetRepresentation.orientation().rawValue)
                    let image = UIImage(CGImage: assetRepresentation.fullResolutionImage().takeUnretainedValue(), scale: 1, orientation: orientation!)
                    if let scaledImage = scaleImage(image) {
                        images.append(scaledImage)
                    }
                }
            }
        }
        return images
    }
    
    func scaleImage(image: UIImage) -> UIImage? {
        //scale size
        let length = max(image.size.width, image.size.height)
        var scaledImage = image
        if length > 1080 {
            scaledImage = image.imageScaled(1080.0/length)
        }
    
        //compress
        let dataLength: CGFloat = CGFloat(UIImageJPEGRepresentation(scaledImage, 1)!.length)
        let data = UIImageJPEGRepresentation(scaledImage, 1000.0/dataLength)
        return UIImage(data: data!);
    }
    
    // MARK: - UITextViewDelegate
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let string = textView.text as NSString
        let changeText = string.substringWithRange(range) as String
//        print("'\(textView.text)'(\(count(textView.text))) - '\(changeText)'(\(count(changeText))) + '\(text)'(\(count(text)))\n")
        return textView.text.characters.count - changeText.characters.count + text.characters.count <= 400
    }
    
}
