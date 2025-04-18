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

@Model
final class NearbySearchResponse: Codable, Equatable {
    var data: [Location]

    private enum CodingKeys: String, CodingKey {
        case data
    }

    init(data: [Location]) {
        self.data = data
    }

    init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decode([Location].self, forKey: .data)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(data, forKey: .data)
    }
}

// MARK: - Location

@Model
final class Location: Codable, Equatable {
    var name: String?

    private enum CodingKeys: String, CodingKey {
        case name
    }

    init(name: String? = nil) {
        self.name = name
    }

    init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }
}
