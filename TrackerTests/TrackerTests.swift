//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by  Admin on 28.11.2024.
//

import Testing

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    
    func testViewController() async {
        let vc = await TrackersViewController()
        await vc.loadViewIfNeeded()
        
        assertSnapshot(of: vc,as: .image(traits: .init(userInterfaceStyle: .dark)))
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
        XCTAssertTrue (true)
    }
}
