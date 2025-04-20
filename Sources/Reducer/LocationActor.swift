//
//  LocationActor.swift
//  NearMe
//
//  Created by Roman Podymov on 18/04/2025.
//  Copyright © 2025 NearMe. All rights reserved.
//

import ComposableArchitecture
import SwiftData

@ModelActor
actor LocationActor {
    private var context: ModelContext { modelExecutor.modelContext }

    func fetchLocations() throws -> [LocationPersistentModelDTO] {
        try context.fetch(FetchDescriptor<Location>()).map {
            .init(id: $0.id, name: $0.name)
        }
    }

    func saveLocations(locations: [LocationPersistentModelDTO]) throws {
        locations.forEach {
            context.insert(Location(name: $0.name))
        }
        try context.save()
    }
}

final class LocationPersistentModelDTO: Sendable, Identifiable {
    let id: PersistentIdentifier?
    let name: String?

    init(
        id: PersistentIdentifier? = nil,
        name: String? = nil
    ) {
        self.id = id
        self.name = name
    }
}

extension LocalStorageClient: DependencyKey {
    static let liveValue = {
        var client = LocalStorageClient()
        client.search = { [locationActor = client.locationActor] _, _ in
            try await locationActor.fetchLocations()
        }
        client.save = { [locationActor = client.locationActor] in
            try await locationActor.saveLocations(locations: $0)
        }
        return client
    }()
}

@DependencyClient
struct LocalStorageClient {
    private let container: ModelContainer
    private let locationActor: LocationActor

    typealias SearchFunction = @Sendable (Double?, Double?) async throws -> [LocationPersistentModelDTO]
    typealias SaveFunction = @Sendable ([LocationPersistentModelDTO]) async throws -> Void

    init() {
        let configuration = ModelConfiguration(for: Location.self)
        let schema = Schema([Location.self])

        // swiftlint:disable force_try
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        // swiftlint:enable force_try
        self.container = container
        locationActor = .init(modelContainer: container)
    }

    var search: SearchFunction!

    var save: SaveFunction!
}

extension LocalStorageClient: TestDependencyKey {
    static let previewValue = {
        var client = Self()
        client.search = { _, _ in
            [LocationPersistentModelDTO(name: "Location1"), LocationPersistentModelDTO(name: "Location2"), LocationPersistentModelDTO(name: "Location3")]
        }
        client.save = { _ in
        }
    }()

    static let testValue = {
        var client = Self()
        client.search = { _, _ in
            [LocationPersistentModelDTO(name: "Location1"), LocationPersistentModelDTO(name: "Location2"), LocationPersistentModelDTO(name: "Location3")]
        }
        client.save = { _ in
        }
    }()
}

extension DependencyValues {
    var localStorageClient: LocalStorageClient {
        get { self[LocalStorageClient.self] }
        set { self[LocalStorageClient.self] = newValue }
    }
}
