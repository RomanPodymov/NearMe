//
//  LocationsClient.swift
//  NearMe
//
//  Created by Roman Podymov on 18/04/2025.
//  Copyright © 2025 NearMe. All rights reserved.
//

import ComposableArchitecture
import Foundation
import Moya

extension LocationsClient: DependencyKey {
    static let liveValue = LocationsClient { latitude, longitude in
        let provider = MoyaProvider<TripAdvisorService>()
        let response = try await provider.requestPublisher(
            .search(
                latitude ?? .zero,
                longitude ?? .zero
            )
        ).values.first { _ in true }
        let processed = try JSONDecoder().decode(NearbySearchResponse.self, from: response?.data ?? .init())
        return processed.data ?? .init()
    }
}

@DependencyClient
struct LocationsClient {
    var search: @Sendable (Double?, Double?) async throws -> [Location]
}

extension LocationsClient: TestDependencyKey {
    static let previewValue = Self(search: { _, _ in
        [Location(name: "Location1"), Location(name: "2"), Location(name: "3")]
    })

    static let testValue = Self()
}

extension DependencyValues {
    var locationsClient: LocationsClient {
        get { self[LocationsClient.self] }
        set { self[LocationsClient.self] = newValue }
    }
}
