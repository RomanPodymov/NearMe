//
//  PlacesView.swift
//  NearMe
//
//  Created by Roman Podymov on 16/04/2025.
//  Copyright © 2025 NearMe. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct PlacesView: View {
    var store: StoreOf<PlacesReducer>

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.scope(state: \.places, action: \.places)) { store in
                    PlaceView(store: store)
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}
