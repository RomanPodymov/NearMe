//
//  PlacesScreen.swift
//  NearMe
//
//  Created by Roman Podymov on 16/04/2025.
//  Copyright © 2025 NearMe. All rights reserved.
//

import CombineMoya
import ComposableArchitecture
import CoreLocation
import Moya
import SwiftData
@preconcurrency import SwiftLocation
import SwiftUI

struct PlacesScreen: View {
    var store: StoreOf<Places>

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.scope(state: \.places, action: \.places)) { store in
                    Text(store.location?.name ?? "")
                }
            }
        }
        .onAppear {
            store.send(.onAppear(modelContext))
        }
    }
}

extension ModelContext: @unchecked @retroactive Sendable {}
