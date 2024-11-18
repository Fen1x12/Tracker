//
//  OnboardingStatus.swift
//  Tracker
//
//  Created by  Admin on 18.11.2024.
//

import Foundation

final class OnboardingStatus {
    private let onboardingKey = "hasSeenOnboarding"

    func setOnboardingSeen() {
        UserDefaults.standard.set(true, forKey: onboardingKey)
    }

    func hasSeenOnboarding() -> Bool {
        return UserDefaults.standard.bool(forKey: onboardingKey)
    }
}
