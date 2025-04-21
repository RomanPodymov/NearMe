//
//  SwiftDataLocationActor.swift
//  NearMe
//
//  Created by Roman Podymov on 18/04/2025.
//  Copyright © 2025 NearMe. All rights reserved.
//

import SwiftData

@ModelActor
actor SwiftDataLocationActor {
    private var context: ModelContext { modelExecutor.modelContext }

    func fetchLocations() throws -> [LocationPersistentModelSwiftData] {
        try context.fetch(FetchDescriptor<Location>()).map {
            .init(id: $0.id, name: $0.name)
        }
    }

    func saveLocations(locations: [LocationPersistentModelSwiftData]) throws {
        locations.forEach {
            context.insert(Location(name: $0.name))
        }
        try context.save()
    }
}
