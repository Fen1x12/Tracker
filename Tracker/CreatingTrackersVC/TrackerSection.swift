//
//  TrackerSection.swift
//  Tracker
//
//  Created by  Admin on 16.10.2024.
//

import Foundation

enum TrackerSection: Int, CaseIterable {
    case textView
    case buttons
    case emoji
    case color
    case createButtons

    var headerTitle: String? {
        switch self {
        case .textView:
            return nil
        case .buttons:
            return nil
        case .emoji:
            return "Emoji"
        case .color:
            return "Цвет"
        case .createButtons:
            return nil
        }
    }
    
    var footerTitle: String? {
        switch self {
        case .textView:
            return "Ограничение 38 символов"
        case .buttons, .emoji, .color, .createButtons:
            return nil
        }
    }
}