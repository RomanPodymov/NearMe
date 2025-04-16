//
//  PlacesScreen.swift
//  NearMe
//
//  Created by Roman Podymov on 16/04/2025.
//  Copyright © 2025 NearMe. All rights reserved.
//

import CombineMoya
import ComposableArchitecture
import Moya
import SwiftUI

@Reducer
struct Places {
    @ObservableState
    struct State: Equatable {
        var places: IdentifiedArrayOf<Place.State> = []
    }

    enum Action: Sendable {
        case onAppear
        case onPlacesReceived([Place.State])
        case places(IdentifiedActionOf<Place>)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let provider = MoyaProvider<TripAdvisorService>()
                    let response = try await provider.requestPublisher(.search(49.7475, 13.3776)).values.first { _ in true }
                    let processed = try JSONDecoder().decode(NearbySearchResponse.self, from: response!.data)
                    await send(.onPlacesReceived(processed.data?.map {
                        Place.State(location: $0)
                    } ?? []))
                }
            case let .onPlacesReceived(places):
                state.places.removeAll()
                for var place in places {
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

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.scope(state: \.places, action: \.places)) { store in
                    PlaceScreen(store: store)
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}
