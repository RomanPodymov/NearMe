//
//  NearbySearchResponse.swift
//  NearMe
//
//  Created by Roman Podymov on 16/04/2025.
//  Copyright © 2025 NearMe. All rights reserved.
//

import Foundation
import SwiftData

// MARK: - NearbySearchResponse

struct NearbySearchResponse: Codable {
    let data: [Location]
}

// MARK: - Location

struct Location: Codable, Equatable {
    let name: String?
}

@Model
final class LocationPersistentModel {
    var name: String?

    init(
        name: String? = nil
    ) {
        self.name = name
    }
}

final class LocationPersistentModelDTO: Sendable, Identifiable {
    let id: PersistentIdentifier
    let name: String?

    enum CodingKeys: String, CodingKey {
        case name
    }

    init(
        id: PersistentIdentifier,
        name: String? = nil
    ) {
        self.id = id
        self.name = name
    }
}
