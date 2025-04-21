//
//  NearMeTests.swift
//  NearMe
//
//  Created by Roman Podymov on 16/04/2025.
//  Copyright © 2025 NearMe. All rights reserved.
//

import ComposableArchitecture
@testable import NearMeApp
import Testing

@Suite
struct NearMeTests {
    @Dependency(\.locationsClient) var locationsClient

    @Test
    func testSome() async throws {
        let locations = try await locationsClient.search(0, 0)
        #expect(locations[0].name == "Location1")
    }
}
