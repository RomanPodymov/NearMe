//
//  PlacesReducer.swift
//  NearMe
//
//  Created by Roman Podymov on 18/04/2025.
//  Copyright © 2025 NearMe. All rights reserved.
//

import CombineMoya
import ComposableArchitecture
import CoreLocation
import Foundation
import Moya
import SwiftData
@preconcurrency import SwiftLocation

@Reducer
struct PlacesReducer {
    @ObservableState
    struct State: Equatable {
        var places: IdentifiedArrayOf<PlaceReducer.State> = []
    }

    enum Action {
        case onAppear
        case onPlacesReceived([Location])
        case places(IdentifiedActionOf<PlaceReducer>)
    }

    let container: ModelContainer
    @Dependency(\.locationsClient) var locationsClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let locationActor = LocationActor(modelContainer: container)
                    if let places = try? await locationActor.fetchLocations(), !places.isEmpty {
                        await send(.onPlacesReceived(places.map {
                            .init(name: $0.name)
                        }))
                        return
                    }

                    let coordinate = try await receiveCoordinate()

                    let locations = try await locationsClient.search(coordinate?.latitude, coordinate?.longitude)
                    try await locationActor.saveLocations(locations: locations.map {
                        LocationPersistentModelDTO(name: $0.name)
                    })
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
            SwiftLocation.Location()
        }.value

        let requestPermissionResult = try await location.requestPermission(.always)
        if requestPermissionResult == .denied || requestPermissionResult == .restricted {
            fatalError()
        }
        return try await location.requestLocation().location?.coordinate
    }

    private func set(state: inout PlacesReducer.State, places: [Location]) {
        state.places.removeAll()
        let states = places.map {
            PlaceReducer.State(location: $0)
        }
        for place in states {
            state.places.append(place)
        }
    }
}
