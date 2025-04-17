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
    let store = Store(initialState: Places.State()) {
        Places()
    }

    var body: some Scene {
        WindowGroup {
            PlacesScreen(store: store)
                .modelContainer(for: Location.self)
        }
    }
}
