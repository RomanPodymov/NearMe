//
//  PlaceReducer.swift
//  NearMe
//
//  Created by Roman Podymov on 18/04/2025.
//  Copyright © 2025 NearMe. All rights reserved.
//

import ComposableArchitecture
import Foundation

@Reducer
struct PlaceReducer {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id: UUID = .init()
        var location: Location?
    }

    enum Action: Sendable {
        case some
    }

    var body: some Reducer<State, Action> {
        EmptyReducer()
    }
}
