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
class NearbySearchResponse: Codable, Equatable {
    var data: [Location]
    var meta: Meta?

    enum CodingKeys: String, CodingKey {
        case data
        case meta
    }

    init(data: [Location], meta: Meta?) {
        self.data = data
        self.meta = meta
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decode([Location].self, forKey: .data)
        meta = try values.decodeIfPresent(Meta.self, forKey: .meta)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(data, forKey: .data)
        try container.encode(meta, forKey: .meta)
    }
}

// MARK: - Location

@Model
final class Location: Codable, Equatable {
    var locationID: String?
    var name: String?
    var address: String?
    var latitude: Double?
    var longitude: Double?
    var rating: Double?
    var reviewCount: Int?
    var imageURL: String?
    var locationType: LocationType?
    var ancestors: [Ancestor]?

    enum CodingKeys: String, CodingKey {
        case locationID = "location_id"
        case name, address, latitude, longitude, rating
        case reviewCount = "review_count"
        case imageURL = "image_url"
        case locationType = "location_type"
        case ancestors
    }

    init(
        locationID: String? = nil,
        name: String? = nil,
        address: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        rating: Double? = nil,
        reviewCount: Int? = nil,
        imageURL: String? = nil,
        locationType: LocationType? = nil,
        ancestors: [Ancestor]? = nil
    ) {
        self.locationID = locationID
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.rating = rating
        self.reviewCount = reviewCount
        self.imageURL = imageURL
        self.locationType = locationType
        self.ancestors = ancestors
    }

    required init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        locationID = try values.decode(String.self, forKey: .locationID)
        name = try values.decode(String.self, forKey: .name)
        address = try values.decodeIfPresent(String.self, forKey: .address)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(address, forKey: .address)
    }
}

// MARK: - Ancestor

@Model
class Ancestor: Codable, Equatable {
    var level: String?
    var name: String?
    var locationID: String?

    enum CodingKeys: String, CodingKey {
        case level, name
        case locationID = "location_id"
    }

    init(level: String? = nil, name: String? = nil, locationID: String? = nil) {
        self.level = level
        self.name = name
        self.locationID = locationID
    }

    required init(from _: any Decoder) throws {}

    func encode(to _: any Encoder) throws {}
}

// MARK: - Meta

@Model
class Meta: Codable, Equatable {
    var status: String?
    var code: Int?
    var message: String?

    enum CodingKeys: String, CodingKey {
        case status
        case code
        case message
    }

    init(status: String? = nil, code: Int? = nil, message: String? = nil) {
        self.status = status
        self.code = code
        self.message = message
    }

    required init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        code = try values.decodeIfPresent(Int.self, forKey: .code)
        message = try values.decodeIfPresent(String.self, forKey: .message)
    }

    func encode(to _: any Encoder) throws {}
}

// MARK: - LocationType

enum LocationType: String, Codable, Equatable {
    case hotel
    case restaurant
    case attraction
}
