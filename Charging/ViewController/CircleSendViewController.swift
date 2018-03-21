//
//  CircleSendViewController.swift
//  Charging
//
//  Created by chenzhibin on 15/9/11.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

import UIKit

protocol CircleSendViewControllerDelegate: class {
    func circleArticleDidSend()
}

class CircleSendViewController: DCViewController {

    weak var delegate: CircleSendViewControllerDelegate?
    @IBOutlet weak var textView: DCTextView!
    @IBOutlet weak var wordsLimitLabel: UILabel!

    @IBOutlet weak var photoViewHeightCons: NSLayoutConstraint!
    @IBOutlet weak var photoButton0: UIButton!
    @IBOutlet weak var photoButton1: UIButton!
    @IBOutlet weak var photoButton2: UIButton!
    @IBOutlet weak var photoButton3: UIButton!
    @IBOutlet weak var photoButton4: UIButton!
    @IBOutlet weak var photoButton5: UIButton!
    var photoButtons: [UIButton] = []
    
    var photoImages: [UIImage] = []
    
    var requestTask: NSURLSessionDataTask?
    
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    var locationService: LocationService?
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.paletteSeparateLineLightGrayColor()
        textView.placeholder = "说说您的想法吧"
//        textView.delegate = self
        navigationItem.rightBarButtonItem?.enabled = false
        
        photoButtons = [photoButton0, photoButton1, photoButton2, photoButton3, photoButton4, photoButton5]
        for (index, button) in photoButtons.enumerate() {
            button.tag = index
        }
        reloadPhotos(photoImages)
        
        // Location
        locationView.hidden = true
        
        locationService = LocationService()
        locationService?.addressUpdatedHandler = { [weak weakSelf = self] (address) in
            guard let strongSelf = weakSelf else {
                return
            }
            strongSelf.locationView.hidden = false
            strongSelf.locationLabel.text = address
        }
        locationService?.startUserLocationService()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CircleSendViewController.textViewDidChangeTextNotification(_:)), name: UITextViewTextDidChangeNotification, object: textView)
    }
    func textViewDidChangeTextNotification(notification : NSNotification){
//        if textView.text.characters.count == 140 {
//            return
//        }
        let notificationTextView = notification.object! as! UITextView
        let toBeString = notificationTextView.text
        
        let selectedRange = notificationTextView.markedTextRange
        if selectedRange != nil{
            let position = notificationTextView.positionFromPosition(selectedRange!.start, offset: 0)
            if((position == nil)){
                if(toBeString.characters.count > 140){
                    notificationTextView.text = (toBeString as NSString).substringToIndex(140)
                }
            }
        }else{
            if(toBeString.characters.count > 140){
                notificationTextView.text = (toBeString as NSString).substringToIndex(140)
            }
        }
        wordsLimitLabel.text = "\(textView.text.characters.count)/140"
        
        updateSendButton()
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        view.endEditing(true)
    }
    
    // MARK: - Navigation
    override func navigateBack(sender: AnyObject!) {
        locationService = nil
        requestTask?.cancel()
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Action
    @IBAction func send(sender: AnyObject) {
        view.endEditing(true)
        let hub = showHUDIndicator()
        if textView.text == "" || textView.text == nil{
            self.hideHUD(hub, withText: "内容不能为空")
            return
        }
        let content = textView.text
        let userId = DCApp.sharedApp().user.userId
        let city = DCArea.findCityByCityName(locationService?.locationAddress)
        requestTask = CircleAPI.postArticleTopic(content, userId: userId, images: photoImages, cityId: city.cityId, completion: {[weak weakSelf = self] (success, errorMessage) in
            guard let strongSelf = weakSelf else {
                return
            }
            if success {
                hub.hide(true)
                strongSelf.delegate?.circleArticleDidSend()
                strongSelf.navigateBack(nil)
            } else {
                strongSelf.hideHUD(hub, withText: errorMessage)
            }
        })
    }
    
    @IBAction func clickedPhoto(sender: UIButton) {
        view.endEditing(true)
        if sender.tag < photoImages.count {
            let browser = KZPhotoBrowser(delegate: self)
            browser.setCurrentPhotoIndex(UInt(sender.tag))
            navigationController?.pushViewController(browser, animated: true)
        }
        else if sender.tag == photoImages.count {
            selectImagePickerSource { [unowned self] (source: UIImagePickerControllerSourceType) -> Void in
                if source == .Camera {
                    let cameraVC = DCImagePickerController()
                    cameraVC.sourceType = source
                    self.presentViewController(cameraVC, animated: true, completion: nil)
                    cameraVC.completion = { (image, originalImage) -> Void in
                        if let scaledImage = self.scaleImage(originalImage) {
                            self.photoImages.append(scaledImage)
                            self.reloadPhotos(self.photoImages)
                        }
                    }
                    
                } else {
                    let imagesPicker = PhotoPickerViewController()
                    imagesPicker.status = .CameraRoll
                    imagesPicker.minCount = self.photoButtons.count - self.photoImages.count
                    imagesPicker.show(self)
                    
                    imagesPicker.callBack = { (assets: AnyObject?) -> Void in
                        let images = self.imagesFromAssets(assets)
                        self.photoImages += images
                        self.reloadPhotos(self.photoImages)
                    }
                }
                
            }
        }
    }
    
    // MARK: - Extension
    func reloadPhotos(images: [UIImage]) {
        for (index, button) in photoButtons.enumerate() {
            button.imageView?.contentMode = .ScaleAspectFill
            if index < images.count {
                button.hidden = false
                button.setImage(images[index], forState: .Normal)
            } else if index == images.count {
                button.hidden = false
                button.setImage(UIImage(named: "help_button_add_photo"), forState: .Normal)
            } else {
                button.hidden = true
                button.setImage(nil, forState: .Normal)
            }
        }
        if images.count < 3 {
            photoViewHeightCons.constant = 110
        } else {
            photoViewHeightCons.constant = 200
        }
        
        updateSendButton()
    }
    
    func updateSendButton() {
        navigationItem.rightBarButtonItem?.enabled = textView.text.characters.count > 0 || photoImages.count > 0
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
        if length > 720 {
            scaledImage = image.imageScaled(1080.0/length)
        }
        
        //compress
        let dataLength: CGFloat = CGFloat(UIImageJPEGRepresentation(scaledImage, 1)!.length)
        let data = UIImageJPEGRepresentation(scaledImage, 1000.0/dataLength)
        return UIImage(data: data!);
    }
    
    deinit { // is dealloc
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextViewTextDidChangeNotification, object: textView)
    }
}

//extension CircleSendViewController: UITextViewDelegate {
//    func textViewDidChange(textView: UITextView) {
//////        wordsLimitLabel.text = "\(textView.text.characters.count)/140"
//////        
//////        updateSendButton()
//    }
////
//    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
////        let string = textView.text as NSString
////        let changeText = string.substringWithRange(range) as String
//        return textView.text.characters.count <= 140
//    }
//}

extension CircleSendViewController: KZPhotoBrowserDelegate {
    func numberOfPhotosInPhotoBrowser(photoBrowser: KZPhotoBrowser!) -> UInt {
        return UInt(photoImages.count)
    }
    
    func photoBrowser(photoBrowser: KZPhotoBrowser!, photoAtIndex index: UInt) -> KZPhoto! {
        let image = photoImages[Int(index)]
        return KZPhoto(image: image)
    }
    
    func photoBrowser(photoBrowser: KZPhotoBrowser!, deletePhotoAtIndex index: UInt) {
        photoImages.removeAtIndex(Int(index))
        photoBrowser.reloadData()
        reloadPhotos(photoImages)
    }
}
