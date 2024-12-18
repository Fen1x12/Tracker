//
//  GradientBorderView.swift
//  Tracker
//
//  Created by  Admin on 26.11.2024.
//

import UIKit

final class GradientBorderView: UIView {
    
    var gradientColors: [UIColor] = [] {
        didSet {
            setNeedsLayout()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let gradient = UIImage.gradientImage(bounds: bounds, colors: gradientColors)
        layer.borderColor = UIColor(patternImage: gradient).cgColor
    }
}

