//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by  Admin on 27.11.2024.
//

import Testing

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    @MainActor
    func testViewController() async {
        let vc = TrackersViewController()
        await vc.loadViewIfNeeded()

        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
}
