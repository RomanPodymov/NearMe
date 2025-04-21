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
        let response = try? await provider.requestPublisher(
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
    }

    static let liveValue = tripAdvisorSource
}

extension LocationsClient: TestDependencyKey {
    static let previewValue = Self(search: { _, _ in
        [Location(name: "Location1"), Location(name: "Location2"), Location(name: "Location3")]
    })

    static let testValue = previewValue
}

// MARK: - LocalStorageClient

extension LocalStorageClient: DependencyKey {
    private static let swiftDataClient: LocalStorageClient = {
        let configuration = ModelConfiguration(for: Location.self)
        let schema = Schema([Location.self])

        // swiftlint:disable force_try
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        // swiftlint:enable force_try
        let locationActor: SwiftDataLocationActor = .init(modelContainer: container)

        var client = LocalStorageClient(
            search: { _, _ in
                try await locationActor.fetchLocations().map {
                    .init(name: $0.name)
                }
            }, save: {
                try await locationActor.saveLocations(locations: $0.map {
                    .init(name: $0.name)
                })
            }
        )

        return client
    }()

    static let liveValue = swiftDataClient
}

extension LocalStorageClient: TestDependencyKey {
    static let previewValue: LocalStorageClient = {
        var client = Self(
            search: { _, _ in
                [.init(name: "Location1"), .init(name: "Location2"), .init(name: "Location3")]
            },
            save: { _ in
            }
        )
        return client
    }()

    static let testValue = previewValue
}

import RealmSwift

extension LocalStorageClient {
    private static let realmClient: LocalStorageClient = {
        let realm = try? Realm()

        var client = LocalStorageClient(search: { _, _ in
            []
        }, save: { _ in

        })

        return client
    }()
}
