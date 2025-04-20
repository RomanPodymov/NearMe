//
//  NearMeApp.swift
//  NearMe
//
//  Created by Roman Podymov on 16/04/2025.
//  Copyright © 2025 NearMe. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

@main
struct NearMeApp: App {
    let store: Store<PlacesReducer.State, PlacesReducer.Action>

    init() {
        store = Store(initialState: PlacesReducer.State()) {
            PlacesReducer()
        }
    }

    var body: some Scene {
        WindowGroup {
            PlacesView(store: store)
        }
    }
}
