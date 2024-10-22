//
//  TRecord.swift
//  Tracker
//
//  Created by  Admin on 16.10.2024.
//

import Foundation

struct TrackerRecord: Hashable, Codable {
    let trackerId: UUID
    let date: String
}

extension TrackerRecord {
    init(from coreData: TrackerRecordCoreData) {
        self.trackerId = coreData.trackerId ?? UUID()
        self.date = coreData.date ?? ""
    }
}
