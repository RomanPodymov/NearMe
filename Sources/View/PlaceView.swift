//
//  PlaceView.swift
//  NearMe
//
//  Created by Roman Podymov on 18/04/2025.
//  Copyright © 2025 NearMe. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct PlaceView: View {
    @Bindable var store: StoreOf<PlaceReducer>

    var body: some View {
        Text(store.location?.name ?? "")
    }
}
