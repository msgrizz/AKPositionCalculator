//
//  Bitfinex.swift
//  AKPositionCalculator
//
//  Created by choukh on 2018/3/17.
//

import Foundation
import Moya

enum Bitfinex {

    case ticker

    struct Ticker: Decodable {
        let mid: String
        let bid: String
        let ask: String
        let last_price: String
        let low: String
        let high: String
        let volume: String
        let timestamp: String
    }
}

extension Bitfinex: TargetType {

    var baseURL: URL {
        return URL(string: "https://api.bitfinex.com/v1")!
    }

    var path: String {
        switch self {
        case .ticker:
            return "/pubticker/btcusd"
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
