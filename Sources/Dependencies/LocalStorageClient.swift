//
//  LocalStorageClient.swift
//  NearMe
//
//  Created by Roman Podymov on 20/04/2025.
//  Copyright © 2025 NearMe. All rights reserved.
//

import ComposableArchitecture
import Foundation
import SwiftData

@DependencyClient
struct LocalStorageClient {
    typealias SearchFunction = @Sendable (Double?, Double?) async throws -> [Location]
    typealias SaveFunction = @Sendable ([Location]) async throws -> Void

    var search: SearchFunction!
    var save: SaveFunction!
}

extension DependencyValues {
    var localStorageClient: LocalStorageClient {
        get { self[LocalStorageClient.self] }
        set { self[LocalStorageClient.self] = newValue }
    }
}
