//
//  TCategory.swift
//  Tracker
//
//  Created by  Admin on 16.10.2024.
//

import Foundation

struct TrackerCategory: Codable {
    let title: String
    let trackers: [Tracker]
}

extension TrackerCategory {
    init(from coreData: TrackerCategoryCoreData) {
        self.title = coreData.title ?? "Без названия"
        self.trackers = (coreData.trackers?.allObjects as? [TrackerCoreData])?.map { Tracker(from: $0) } ?? []
    }
}
