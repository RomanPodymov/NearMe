//
//  LocationPersistentModelSwiftData.swift
//  NearMe
//
//  Created by Roman Podymov on 21/04/2025.
//  Copyright © 2025 NearMe. All rights reserved.
//

import SwiftData

final class LocationPersistentModelSwiftData: Sendable, Identifiable {
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
