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

enum TripAdvisor {
    case search(Double, Double)
}

extension TripAdvisor: TargetType {
    var baseURL: URL {
        URL(string: "https://api.content.tripadvisor.com")!
    }

    var path: String {
        "/api/v1/location/nearby_search"
    }

    var method: Moya.Method {
        .get
    }

    var task: Moya.Task {
        switch self {
        case let .search(lat, lon):
            let params = [
                "latLong": "\(lat),\(lon)",
                "key": "",
                "language": "en",
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        nil
    }
}

@Reducer
struct Places {
    @ObservableState
    struct State: Equatable {
        var places: IdentifiedArrayOf<Place.State> = [.init(), .init(), .init(), .init()]
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
                    let provider = MoyaProvider<TripAdvisor>()
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
