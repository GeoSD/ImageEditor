//
//  ViewController.swift
//  ImageEditor
//
//  Created by Georgy Dyagilev on 09/04/2018.
//  Copyright © 2018 Dyagilev developer. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: Define all Outlets

    @IBOutlet weak var loadImageButton: UIButton!
    
    @IBOutlet weak var rotateButton: UIButton!
    @IBOutlet weak var invertColorsButton: UIButton!
    @IBOutlet weak var mirrorImageButton: UIButton!
    
    @IBOutlet weak var originalImage: UIImageView!
    @IBOutlet weak var resultImage: UIImageView!
    
    @IBOutlet var resultImageTap: UITapGestureRecognizer!
    @IBOutlet var originalImageTap: UITapGestureRecognizer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: All actions
    
    @IBAction func selectImageButtonTapped(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        loadImageButton.isHidden = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func originalImageTapped(_ sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func rotateButtonTapped(_ sender: UIButton) {
        resultImage.image = resultImage.image?.rotate(radians: .pi/2)
    }
    
    @IBAction func invertColorButtonTapped(_ sender: UIButton) {
        resultImage.image = resultImage.image?.colorFiltered
    }
    
    @IBAction func mirrorImageButtonTapped(_ sender: UIButton) {
        resultImage.image = resultImage.image?.withHorizontallyFlippedOrientation()
    }
    
    @IBAction func resultImageTapped(_ sender: AnyObject) {
        if resultImage.image == nil {
            let alert = UIAlertController(title: "Warning!",
                                          message: "Please, select image first.",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            let imageData = UIImagePNGRepresentation(resultImage.image!)
            let compressedImage = UIImage(data: imageData!)
            UIImageWriteToSavedPhotosAlbum(compressedImage!, nil, nil, nil)
                
            let alert = UIAlertController(title: "Saved!",
                                          message: "Your image has been saved.",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: Function for selecting picture

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        originalImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        resultImage.image = originalImage.image
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: Function for rotating picture

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero,size: self.size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContext(newSize);
        let context = UIGraphicsGetCurrentContext()!
        
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        context.rotate(by: CGFloat(radians))
        
        self.draw(in: CGRect(x: -self.size.width/2,
                             y: -self.size.height/2,
                             width: self.size.width,
                             height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

// MARK: Function for applying color filter

extension UIImage {
    var colorFiltered: UIImage? {
        let context = CIContext(options: nil)
        guard let currentFilter = CIFilter(name: "CIPhotoEffectMono") else { return nil }
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        if let output = currentFilter.outputImage,
            let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }
        return nil
    }
}
