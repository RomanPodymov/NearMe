//
//  PlacesScreen.swift
//  NearMe
//
//  Created by Roman Podymov on 16/04/2025.
//  Copyright © 2025 NearMe. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct Places {
    @ObservableState
    struct State: Equatable {
        var someData: IdentifiedArrayOf<Place.State> = [.init(), .init(), .init(), .init()]
    }

    enum Action: Sendable {
        case places(IdentifiedActionOf<Place>)
    }

    var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .places:
                return .none
            }
        }
        .forEach(\.someData, action: \.places) {
            Place()
        }
    }
}

struct PlacesScreen: View {
    var store: StoreOf<Places>

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.scope(state: \.someData, action: \.places)) { store in
                    PlaceScreen(store: store)
                }
            }
        }
    }
}
