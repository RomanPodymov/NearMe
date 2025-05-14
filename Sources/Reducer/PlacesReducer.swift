//
//  PlacesReducer.swift
//  NearMe
//
//  Created by Roman Podymov on 18/04/2025.
//  Copyright © 2025 NearMe. All rights reserved.
//

import ComposableArchitecture
import CoreLocation
import Foundation
import Moya
@preconcurrency import SwiftLocation

@Reducer
struct PlacesReducer {
    @ObservableState
    struct State: Equatable {
        var places: IdentifiedArrayOf<PlaceReducer.State> = []
    }

    enum Action {
        case onAppear
        case onPlacesReceived([TripLocation])
        case places(IdentifiedActionOf<PlaceReducer>)
    }

    @Dependency(\.localStorageClient) var localStorageClient
    @Dependency(\.locationsClient) var locationsClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    if let places = try? await localStorageClient.search(nil, nil), !places.isEmpty {
                        await send(.onPlacesReceived(places))
                        return
                    }

                    let coordinate = try await receiveCoordinate()

                    let locations = try await locationsClient.search(coordinate?.latitude, coordinate?.longitude)
                    try await localStorageClient.save(locations)
                    await send(.onPlacesReceived(locations))
                }
            case let .onPlacesReceived(places):
                set(state: &state, places: places)
                return .none
            case .places:
                return .none
            }
        }
    }

    private func receiveCoordinate() async throws -> CLLocationCoordinate2D? {
        let location = await _Concurrency.Task { @MainActor in
            Location()
        }.value

        let requestPermissionResult = try await location.requestPermission(.always)
        if requestPermissionResult == .denied || requestPermissionResult == .restricted {
            fatalError()
        }
        return try await location.requestLocation().location?.coordinate
    }

    private func set(state: inout PlacesReducer.State, places: [TripLocation]) {
        state.places.removeAll()
        let states = places.map {
            PlaceReducer.State(location: $0)
        }
        for place in states {
            state.places.append(place)
        }
    }
}
