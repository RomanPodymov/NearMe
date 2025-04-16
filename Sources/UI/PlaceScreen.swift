//
//  PlaceScreen.swift
//  NearMe
//
//  Created by Roman Podymov on 16/04/2025.
//  Copyright © 2025 NearMe. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct Place {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id: UUID = .init()
        var description = "Some"
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
        Text(store.description)
    }
}
