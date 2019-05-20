//
//  BallView.swift
//  Lines
//
//  Created by Color Lines on 18/05/2019.
//  Copyright © 2019 MacService. All rights reserved.
//

import UIKit
class BallView: UIView {
    var color = 1 { didSet { setNeedsDisplay() } }
    var row: CGFloat = 0 { didSet { frame = cellRect } }
    var column: CGFloat = 0 { didSet { frame = cellRect } }
    var cellWidth: CGFloat = 0 { didSet { frame = cellRect } }
    var cellRect: CGRect {
        return CGRect(x: column * cellWidth,
                      y: row * cellWidth,
                      width: cellWidth,
                      height: cellWidth)
    }
    override func draw(_ rect: CGRect) {
        if let image = UIImage(named: "\(color)") {
            image.draw(in: bounds)
        }
    }
}
