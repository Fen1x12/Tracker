//
//  ConfiguratorFactory.swift
//  Tracker
//
//  Created by  Admin on 16.10.2024.
//

import UIKit

final class LayoutConfiguratorFactory {
    static func create(for type: TrackerViewControllerType?) -> LayoutConfigurator {
        switch type {
        case .typeTrackers:
            return TypeTrackersLayoutConfigurator()
        case .category, .creatingTracker, .schedule:
            return DefaultLayoutConfigurator()
        case .none:
            return DefaultLayoutConfigurator()
        }
    }
}
