//
//  Bitstamp.swift
//  AKPositionCalculator
//
//  Created by choukh on 2018/3/17.
//

import Foundation
import Moya

enum Bitstamp {

    case ticker

    struct Ticker: Decodable {
        let high: String
        let last: String
        let timestamp: String
        let bid: String
        let vwap: String
        let volume: String
        let low: String
        let ask: String
        let open: Double
    }
}

extension Bitstamp: TargetType {

    var baseURL: URL {
        return URL(string: "https://www.bitstamp.net/api")!
    }

    var path: String {
        switch self {
        case .ticker:
            return "/ticker"
        }
    }

    var method: Moya.Method {
        switch self {
        case .ticker:
            return .get
        }
    }

    var sampleData: Data {
        return Data()
    }

    var task: Task {
        switch self {
        case .ticker:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}
