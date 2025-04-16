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
        ""
    }

    var method: Moya.Method {
        .get
    }

    var task: Moya.Task {
        .requestPlain
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
        case places(IdentifiedActionOf<Place>)
    }

    var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .onAppear:
                let provider = MoyaProvider<TripAdvisor>()
                provider.request(.search(100, 200)) { result in
                    switch result {
                    case let .success(moyaResponse):
                        let data = moyaResponse.data
                        let statusCode = moyaResponse.statusCode

                    case let .failure(error):
                        break
                    }
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
