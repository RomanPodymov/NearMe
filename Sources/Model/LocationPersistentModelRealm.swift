//
//  LocationPersistentModelRealm.swift
//  NearMe
//
//  Created by Roman Podymov on 21/04/2025.
//  Copyright © 2025 NearMe. All rights reserved.
//

import RealmSwift

final class LocationPersistentModelRealm: Object {
    @Persisted var name: String?
}
