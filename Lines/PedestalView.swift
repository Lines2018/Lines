//
//  PedestalView.swift
//  Lines
//
//  Created by Color Lines on 20/05/2019.
//  Copyright © 2019 MacService. All rights reserved.
//

import UIKit
@IBDesignable
class PedestalView: UIView {
    @IBInspectable
    var score: Int = 0 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var highScore: Int = 100 { didSet { setNeedsDisplay() } }
    override func draw(_ rect: CGRect) {
        var pedestalRect = CGRect(x: 0,
                                  y: bounds.size.height - scale * ImageSize.imageHeight,
                                  width: bounds.size.width,
                                  height: scale * ImageSize.imageHeight)
        if self.pedestalScaledHeight >= 0 {
            if let image = UIImage(named: "pedestal", in: Bundle(for: self.classForCoder), compatibleWith: traitCollection) {
                image.draw(in: pedestalRect)
            }
            pedestalRect.origin.y -= ImageSize.pedestalMinHeight * scale
            switch self.tag {
            case 0:
                if score > highScore {
                    pedestalRect.origin.y -= self.pedestalScaledHeight * (CGFloat(highScore) / CGFloat(score))
                } else {
                    pedestalRect.origin.y -= self.pedestalScaledHeight
                }
            case 1:
                if score > highScore {
                    pedestalRect.origin.y -= self.pedestalScaledHeight
                } else {
                    pedestalRect.origin.y -= self.pedestalScaledHeight * (CGFloat(score) / CGFloat(highScore))
                }
            default: break
            }
        }
        if let image = UIImage(named: imageName, in: Bundle(for: self.classForCoder), compatibleWith: traitCollection) {
            image.draw(in: pedestalRect)
        }
    }
}
extension PedestalView {
    private struct ImageSize {
        static let imageHeight = CGFloat(300.0)
        static let imageWidth = CGFloat(83.0)
        static let kingHeight = CGFloat(98.0)
        static let pedestalMinHeight = CGFloat(13.0)
    }
    private var scale: CGFloat {
        return bounds.size.width / ImageSize.imageWidth
    }
    private var pedestalScaledHeight: CGFloat {
        return bounds.size.height - scale * (ImageSize.kingHeight + ImageSize.pedestalMinHeight)
    }
    private var imageName: String {
        switch self.tag {
        case 0:
            if score > highScore {
                return "king"
            } else {
                return "kingwin"
            }
        case 1:
            if score > highScore {
                return "playerwin"
            } else {
                return "player"
            }
        default: return ""
        }
    }
}
