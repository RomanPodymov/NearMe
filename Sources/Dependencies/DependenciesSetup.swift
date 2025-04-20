//
//  DependenciesSetup.swift
//  NearMe
//
//  Created by Roman Podymov on 20/04/2025.
//  Copyright © 2025 NearMe. All rights reserved.
//

import ComposableArchitecture
import Foundation
import Moya
import SwiftData

// MARK: - LocationsClient

extension LocationsClient: DependencyKey {
    private static let tripAdvisorSource = LocationsClient { latitude, longitude throws (LocationsClientError) in
        let provider = MoyaProvider<TripAdvisorService>()
        do {
            let response = try await provider.requestPublisher(
                .search(
                    latitude ?? .zero,
                    longitude ?? .zero
                )
            ).values.first { _ in true }
            guard let data = response?.data else {
                throw LocationsClientError.requestError
            }
            guard let processed = try? JSONDecoder().decode(NearbySearchResponse.self, from: data),
                  let result = processed.data
            else {
                throw LocationsClientError.parseError
            }
            return result
        } catch {
            throw LocationsClientError.requestError
        }
    }

    static let liveValue = tripAdvisorSource
}

extension LocationsClient: TestDependencyKey {
    static let previewValue = Self(search: { _, _ in
        [Location(name: "Location1"), Location(name: "2"), Location(name: "3")]
    })

    static let testValue = previewValue
}

// MARK: - LocalStorageClient

extension LocalStorageClient: DependencyKey {
    static let liveValue: LocalStorageClient = {
        let configuration = ModelConfiguration(for: Location.self)
        let schema = Schema([Location.self])

        // swiftlint:disable force_try
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        // swiftlint:enable force_try
        let locationActor: SwiftDataLocationActor = .init(modelContainer: container)

        var client = LocalStorageClient()
        client.search = { _, _ in
            try await locationActor.fetchLocations().map {
                .init(name: $0.name)
            }
        }
        client.save = {
            try await locationActor.saveLocations(locations: $0.map {
                .init(name: $0.name)
            })
        }

        return client
    }()
}

extension LocalStorageClient: TestDependencyKey {
    static let previewValue: LocalStorageClient = {
        var client = Self()
        client.search = { _, _ in
            [.init(name: "Location1"), .init(name: "Location2"), .init(name: "Location3")]
        }
        client.save = { _ in
        }
        return client
    }()

    static let testValue = previewValue
}
