//
//  TripAdvisorService.swift
//  NearMe
//
//  Created by Roman Podymov on 16/04/2025.
//  Copyright © 2025 NearMe. All rights reserved.
//

import CombineMoya
import Foundation
import Moya

enum TripAdvisorService {
    case search(Double, Double)
}

extension TripAdvisorService: TargetType {
    var baseURL: URL {
        URL(string: "https://api.content.tripadvisor.com")!
    }

    var path: String {
        "/api/v1/location/nearby_search"
    }

    var method: Moya.Method {
        .get
    }

    var task: Moya.Task {
        switch self {
        case let .search(lat, lon):
            let params = [
                "latLong": "\(lat),\(lon)",
                "key": "",
                "language": "en",
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        nil
    }
}
