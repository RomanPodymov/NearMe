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
import RealmSwift
import SwiftData

// MARK: - LocationsClient

extension LocationsClient: DependencyKey {
    private static let tripAdvisorSource = LocationsClient { latitude, longitude throws (LocationsClientError) in
        let provider = MoyaProvider<TripAdvisorService>(plugins: [
            NetworkLoggerPlugin(configuration: .init(
                logOptions: [.requestBody, .successResponseBody, .errorResponseBody]
            )),
        ])
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

        return LocalStorageClient(
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
    }()

    private static let realmClient: LocalStorageClient = .init(search: { _, _ in
        let realm = try Realm()
        return realm.objects(LocationPersistentModelRealm.self).map {
            Location(name: $0.name)
        }
    }, save: { locations in
        let realm = try Realm()
        for location in locations {
            try realm.write {
                let obj = LocationPersistentModelRealm()
                obj.name = location.name
                realm.add(obj)
            }
        }
    })

    static let liveValue = realmClient // swiftDataClient
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
