//
//  PlacesScreen.swift
//  NearMe
//
//  Created by Roman Podymov on 16/04/2025.
//  Copyright © 2025 NearMe. All rights reserved.
//

import CombineMoya
import ComposableArchitecture
import CoreLocation
import Moya
import SwiftData
@preconcurrency import SwiftLocation
import SwiftUI

@ModelActor
actor LocationActor {
    private var context: ModelContext { modelExecutor.modelContext }

    func fetchLocations() throws -> [LocationPersistentModelDTO] {
        try context.fetch(FetchDescriptor<LocationPersistentModel>()).map {
            .init(id: $0.id, name: $0.name)
        }
    }

    func saveLocations(locations: [LocationPersistentModel]) throws {
        locations.forEach {
            context.insert($0)
        }
        try context.save()
    }
}

@Reducer
struct Places {
    @ObservableState
    struct State: Equatable {
        var places: IdentifiedArrayOf<Place.State> = []
    }

    enum Action {
        case onAppear(ModelContext)
        case onPlacesReceived([Location])
        case places(IdentifiedActionOf<Place>)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .onAppear(modelContext):
                return .run { send in
                    let locationActor = LocationActor(modelContainer: modelContext.container)
                    if let places = try? await locationActor.fetchLocations(), !places.isEmpty {
                        await send(.onPlacesReceived(places.map {
                            .init(name: $0.name)
                        }))
                        return
                    }
                    let location = await _Concurrency.Task { @MainActor in
                        SwiftLocation.Location()
                    }.value

                    // _ = try await location.requestPermission(.always)

                    let coordinate = try await location.requestLocation().location?.coordinate

                    let provider = MoyaProvider<TripAdvisorService>()
                    let response = try await provider.requestPublisher(
                        .search(
                            coordinate?.latitude ?? .zero,
                            coordinate?.longitude ?? .zero
                        )
                    ).values.first { _ in true }
                    let processed = try JSONDecoder().decode(NearbySearchResponse.self, from: response!.data)
                    try await locationActor.saveLocations(locations: processed.data.map {
                        .init(name: $0.name)
                    })
                    await send(.onPlacesReceived(processed.data))
                }
            case let .onPlacesReceived(places):
                set(state: &state, places: places)
                return .none
            case .places:
                return .none
            }
        }
    }

    private func set(state: inout Places.State, places: [Location]) {
        state.places.removeAll()
        let states = places.map {
            Place.State(location: $0)
        }
        for place in states {
            state.places.append(place)
        }
    }
}

struct PlacesScreen: View {
    var store: StoreOf<Places>

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.scope(state: \.places, action: \.places)) { store in
                    PlaceScreen(store: store)
                }
            }
        }
        .onAppear {
            store.send(.onAppear(modelContext))
        }
    }
}

extension ModelContext: @unchecked @retroactive Sendable {}
