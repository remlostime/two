//
//  ImageHelper.swift
//  SNS-Realtime
//
//  Created by Icaro Lavrador on 25/04/16.
//  Copyright © 2016 Icaro Barreira Lavrador. All rights reserved.
//

import Foundation

class ImageHelper{
  
  static func resizeImage(image: UIImage) -> UIImage{
    
    let size = image.size.applying(CGAffineTransform(scaleX: 0.5, y: 0.5))
    let scale:CGFloat = 0
    let hasAlpha = false
    
    UIGraphicsBeginImageContextWithOptions(size, hasAlpha, scale)
    image.draw(in: CGRect(origin: .zero, size: size))
    let finalImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return finalImage!
  }
}
