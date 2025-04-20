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
actor SwiftDataLocationActor {
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
