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
    private let container: ModelContainer
    let locationActor: SwiftDataLocationActor

    typealias SearchFunction = @Sendable (Double?, Double?) async throws -> [LocationPersistentModelDTO]
    typealias SaveFunction = @Sendable ([LocationPersistentModelDTO]) async throws -> Void

    init() {
        let configuration = ModelConfiguration(for: Location.self)
        let schema = Schema([Location.self])

        // swiftlint:disable force_try
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        // swiftlint:enable force_try
        self.container = container
        locationActor = .init(modelContainer: container)
    }

    var search: SearchFunction!

    var save: SaveFunction!
}

extension DependencyValues {
    var localStorageClient: LocalStorageClient {
        get { self[LocalStorageClient.self] }
        set { self[LocalStorageClient.self] = newValue }
    }
}
