//
//  ImageViewController.swift
//  Cat VS Dog
//
//  Created by Garima Bothra on 05/05/20.
//  Copyright © 2020 Garima Bothra. All rights reserved.
//

import UIKit
import CoreML

class ImageViewController: UIViewController {
    //Create outlets
    @IBOutlet weak var previewImageView: UIImageView!
    //Create variables
    var previewImage: UIImage!
    var model = classifier()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageView()
        // Do any additional setup after loading the view.
    }
    
    func setupImageView() {
        self.previewImageView.image = previewImage
    }

    @IBAction func predictItem(_ sender: Any) {

        getModelPrediction()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = storyboard.instantiateViewController(withIdentifier: "home") as! ViewController
        self.navigationController!.pushViewController(homeViewController, animated: true) 
    }

    func resizedImageWith(image: UIImage) -> UIImage {
           let newSize = CGSize(width: 64,  height: 64)
           let rect = CGRect(x: 0, y: 0, width: 64, height: 64)
           UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
           image.draw(in: rect)
           let newImage = UIGraphicsGetImageFromCurrentImageContext()
           UIGraphicsEndImageContext()
           return newImage!
       }

    //Function to predict using model and use the output accordingly

    func getModelPrediction() {
        let input = resizedImageWith(image: previewImage).pixelBuffer()
        let prediction = try? model.prediction(image: input!)
        for (_, value) in prediction!.output {
            if value == 0.0 {
                let catsCount = UserDefaults.standard.integer(forKey: "catCount") + 1
                    UserDefaults.standard.set(catsCount, forKey: "catCount")
            }
            else {
                let dogCount = UserDefaults.standard.integer(forKey: "dogCount") + 1
                UserDefaults.standard.set(dogCount, forKey: "dogCount")
            }
        }
    }
}

extension UIImage {

    func pixelBuffer() -> CVPixelBuffer? {
// NOTE: Create pixel buffer with specified pixel format
var pixelBuffer: CVPixelBuffer?
let options = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
let status = CVPixelBufferCreate(kCFAllocatorDefault, 64, 64, kCVPixelFormatType_32ARGB, options, &pixelBuffer)
guard status == kCVReturnSuccess, let finalPixelBuffer = pixelBuffer else {
    return nil
}
        // NOTE: Create context ("canvas") for drawing pixels
               CVPixelBufferLockBaseAddress(finalPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
               let pixelData = CVPixelBufferGetBaseAddress(finalPixelBuffer)
               let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
               guard let context = CGContext(data: pixelData, width: Int(64), height: 64, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(finalPixelBuffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
                   return nil
               }
               context.translateBy(x: 0, y: 64)
               context.scaleBy(x: 1.0, y: -1.0)

               // NOTE: Draw pixels on the context, updates pixel buffer
               UIGraphicsPushContext(context)
               draw(in: CGRect(x: 0, y: 0, width: 64, height: 64))
               UIGraphicsPopContext()
               CVPixelBufferUnlockBaseAddress(finalPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))

               return finalPixelBuffer
}
}
