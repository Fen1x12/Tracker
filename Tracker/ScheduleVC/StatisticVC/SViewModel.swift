//
//  SViewModel.swift
//  Tracker
//
//  Created by  Admin on 18.11.2024.
//

import Foundation

final class StatisticsViewModel {
    var statistics: StatisticsData? = nil
    
    var hasStatistics: Bool {
        return statistics != nil
    }
    
    func fetchStatistics() {
        statistics = StatisticsData(
            bestPeriod: 6,
            idealDays: 2,
            completedTrackers: 5,
            averageValue: 4
        )
    }
}
