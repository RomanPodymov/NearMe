//
//  PlaceReducer.swift
//  NearMe
//
//  Created by Roman Podymov on 18/04/2025.
//  Copyright © 2025 NearMe. All rights reserved.
//

import Foundation
import ComposableArchitecture

@Reducer
struct Place {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id: UUID = UUID()
        let location: Location
    }

    enum Action {
        case some
    }

    var body: some Reducer<State, Action> {
        EmptyReducer()
    }
}
