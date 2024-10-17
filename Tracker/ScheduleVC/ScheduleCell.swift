//
//  ScheduleCell.swift
//  Tracker
//
//  Created by  Admin on 16.10.2024.
//

import UIKit

final class ScheduleCell: CategoryBaseCell {
    static let reuseIdentifier = "ScheduleCell"
    
    override func configure(with text: String, showSwitch: Bool = true, isSwitchOn: Bool = false) {
        super.configure(with: text, showSwitch: showSwitch, isSwitchOn: isSwitchOn)
    }
}
