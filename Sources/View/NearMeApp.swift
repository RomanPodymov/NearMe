//
//  NearMeApp.swift
//  NearMe
//
//  Created by Roman Podymov on 16/04/2025.
//  Copyright © 2025 NearMe. All rights reserved.
//

import ComposableArchitecture
import SwiftData
import SwiftUI

@main
struct NearMeApp: App {
    let store: Store<PlacesReducer.State, PlacesReducer.Action>
    let container: ModelContainer

    init() {
        let configuration = ModelConfiguration(for: Location.self)
        let schema = Schema([Location.self])

        // swiftlint:disable force_try
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        // swiftlint:enable force_try
        self.container = container
        store = Store(initialState: PlacesReducer.State()) {
            PlacesReducer(container: container)
        }
    }

    var body: some Scene {
        WindowGroup {
            PlacesView(store: store)
                .modelContainer(container)
        }
    }
}
