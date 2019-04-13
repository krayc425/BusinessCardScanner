//
//  UIImageExtensions.swift
//  BusinessCardScanner
//
//  Created by 宋 奎熹 on 2018/7/31.
//  Copyright © 2018 宋 奎熹. All rights reserved.
//

import UIKit

extension UIImage {

    func compressImage(maxLength: Int) -> UIImage {
        let tempMaxLength: Int = maxLength / 8
        var compression: CGFloat = 1
        guard var data = self.jpegData(compressionQuality: compression),
            data.count > tempMaxLength else {
            return self
        }
        
        var max: CGFloat = 1
        var min: CGFloat = 0
        for _ in 0..<6 {
            compression = (max + min) / 2
            data = self.jpegData(compressionQuality: compression)!
            if CGFloat(data.count) < CGFloat(tempMaxLength) * 0.9 {
                min = compression
            } else if data.count > tempMaxLength {
                max = compression
            } else {
                break
            }
        }
        var resultImage: UIImage = UIImage(data: data)!
        if data.count < tempMaxLength {
            return resultImage
        }
        
        var lastDataLength: Int = 0
        while data.count > tempMaxLength && data.count != lastDataLength {
            lastDataLength = data.count
            let ratio: CGFloat = CGFloat(tempMaxLength) / CGFloat(data.count)
            let size: CGSize = CGSize(width: Int(resultImage.size.width * sqrt(ratio)),
                                      height: Int(resultImage.size.height * sqrt(ratio)))
            UIGraphicsBeginImageContext(size)
            resultImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            resultImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            data = resultImage.jpegData(compressionQuality: compression)!
        }
        return resultImage
    }
    
    func cropping(to: CGRect) -> UIImage? {
        var opaque = false
        if let cgImage = cgImage {
            switch cgImage.alphaInfo {
            case .noneSkipLast, .noneSkipFirst:
                opaque = true
            default:
                break
            }
        }
        UIGraphicsBeginImageContextWithOptions(to.size, opaque, 0.0)
        draw(at: CGPoint(x: -to.origin.x, y: -to.origin.y))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    
}
