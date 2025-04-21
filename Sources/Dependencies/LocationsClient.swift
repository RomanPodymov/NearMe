//
//  LocationsClient.swift
//  NearMe
//
//  Created by Roman Podymov on 18/04/2025.
//  Copyright © 2025 NearMe. All rights reserved.
//

import ComposableArchitecture
import Foundation

enum LocationsClientError: Error {
    case requestError
    case parseError
}

@DependencyClient
struct LocationsClient {
    typealias SearchFunction = @Sendable (Double?, Double?) async throws (LocationsClientError) -> [Location]

    var search: SearchFunction
}

extension DependencyValues {
    var locationsClient: LocationsClient {
        get { self[LocationsClient.self] }
        set { self[LocationsClient.self] = newValue }
    }
}
