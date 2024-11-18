//
//  Cell.swift
//  Tracker
//
//  Created by  Admin on 16.10.2024.
//

import UIKit

final class CategoryCell: CategoryBaseCell {
    static let reuseIdentifier = "CategoryCell"
    
    override func configure(with text: String, showSwitch: Bool = false, isSwitchOn: Bool = false) {
        super.configure(with: text, showSwitch: showSwitch, isSwitchOn: isSwitchOn)
    }
}
