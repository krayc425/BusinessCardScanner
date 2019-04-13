//
//  VisualizeRectanlgesView.swift
//  Piaojia
//
//  Created by 宋 奎熹 on 2019/2/12.
//  Copyright © 2019 Kuixi Song. All rights reserved.
//

import UIKit

extension CGImagePropertyOrientation {
    
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up:
            self = .up
        case .upMirrored:
            self = .upMirrored
        case .down:
            self = .down
        case .downMirrored:
            self = .downMirrored
        case .left:
            self = .left
        case .leftMirrored:
            self = .leftMirrored
        case .right:
            self = .right
        case .rightMirrored:
            self = .rightMirrored
        }
    }
    
}

class VisualizeRectanlgesView: UIView {
    
    var rectangles: [CGRect] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    static func convertedRect(rect: CGRect, to size: CGSize) -> CGRect {
        return CGRect(x: rect.minX * size.width,
                      y: (1.0 - rect.maxY) * size.height,
                      width: rect.width * size.width,
                      height: rect.height * size.height)
    }
    
    override func draw(_ rect: CGRect) {
        backgroundColor = UIColor.clear
        UIColor.blue.setStroke()
        for rect in rectangles {
            let path = UIBezierPath(rect: VisualizeRectanlgesView.convertedRect(rect: rect, to: frame.size))
            path.lineWidth = 3
            path.stroke()
        }
    }
    
}
