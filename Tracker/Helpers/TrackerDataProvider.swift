//
//  TrackerDataProvider.swift
//  Tracker
//
//  Created by  Admin on 27.11.2024.
//

import Foundation

// MARK: - TrackerDataProvider
protocol TrackerDataProvider {
    var numberOfItems: Int { get }
    func item(at index: Int) -> String?
}
