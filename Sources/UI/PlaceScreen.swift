//
//  PlaceScreen.swift
//  NearMe
//
//  Created by Roman Podymov on 16/04/2025.
//  Copyright © 2025 NearMe. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

// MARK: - NearbySearchResponse

struct NearbySearchResponse: Codable, Equatable {
    let data: [Location]?
    let meta: Meta?
}

// MARK: - Location

struct Location: Codable, Equatable {
    let locationID: String?
    let name: String?
    let address: String?
    let latitude: Double?
    let longitude: Double?
    let rating: Double?
    let reviewCount: Int?
    let imageURL: String?
    let locationType: LocationType?
    let ancestors: [Ancestor]?

    enum CodingKeys: String, CodingKey {
        case locationID = "location_id"
        case name, address, latitude, longitude, rating
        case reviewCount = "review_count"
        case imageURL = "image_url"
        case locationType = "location_type"
        case ancestors
    }
}

// MARK: - Ancestor

struct Ancestor: Codable, Equatable {
    let level: String?
    let name: String?
    let locationID: String?

    enum CodingKeys: String, CodingKey {
        case level, name
        case locationID = "location_id"
    }
}

// MARK: - Meta

struct Meta: Codable, Equatable {
    let status: String?
    let code: Int?
    let message: String?
}

// MARK: - LocationType

enum LocationType: String, Codable, Equatable {
    case hotel
    case restaurant
    case attraction
}

@Reducer
struct Place {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id: UUID = .init()
        var location: Location?
    }

    enum Action: Sendable {
        case some
    }

    var body: some Reducer<State, Action> {
        EmptyReducer()
    }
}

struct PlaceScreen: View {
    @Bindable var store: StoreOf<Place>

    var body: some View {
        Text(store.location?.name ?? "")
    }
}
