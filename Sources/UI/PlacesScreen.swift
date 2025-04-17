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
import SwiftLocation
import SwiftUI

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
                /* if let places = try? modelContext.fetch(FetchDescriptor<Location>()), !places.isEmpty {
                     state.places.removeAll()
                     let states = places.map {
                         Place.State(location: $0)
                     }
                     for place in states {
                         state.places.append(place)
                     }
                     return .none
                 } */
                return .run { send in
                    let coordinate = try await _Concurrency.Task { @MainActor in
                        let location = SwiftLocation.Location()
                        // _ = try await location.requestPermission(.always)
                        return try await location.requestLocation().location?.coordinate
                    }.value

                    let provider = MoyaProvider<TripAdvisorService>()
                    let response = try await provider.requestPublisher(
                        .search(
                            coordinate?.latitude ?? .zero,
                            coordinate?.longitude ?? .zero
                        )
                    ).values.first { _ in true }
                    let processed = try JSONDecoder().decode(NearbySearchResponse.self, from: response!.data)
                    processed.data.forEach {
                        modelContext.insert($0)
                    }
                    do {
                        try modelContext.save()
                    } catch {
                        print(error)
                    }
                    await send(.onPlacesReceived(processed.data))
                }
            case let .onPlacesReceived(places):
                state.places.removeAll()
                let states = places.map {
                    Place.State(location: $0)
                }
                for place in states {
                    state.places.append(place)
                }
                return .none
            case .places:
                return .none
            }
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

extension Tasks.ContinuousUpdateLocation.StreamEvent: @retroactive @unchecked Sendable {}
