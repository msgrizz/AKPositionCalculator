//
//  GradientParam.swift
//  AKPositionCalculator
//
//  Created by choukh on 2018/3/17.
//

import Foundation

struct Gradient: Codable {

    enum Position: Codable {
        case btc(Double)
        case dollar(Double)
    }

    let position: Position
    let startPrice: Double
    let endPrice: Double
    let interval: Double
    let description: String

    private var orderCount: Int? {
        return Int(exactly: ceil(abs(startPrice - endPrice) / interval)).map { $0 + 1 }
    }

    private var btcPortion: Double? {
        switch position {
        case .btc(let value):
            return orderCount.map { value / Double($0) }
        case .dollar(let value):
            return orderCount.map { (value / average) / Double($0) }
        }
    }

    private var dollarPortion: Double? {
        switch position {
        case .btc(let value):
            return orderCount.map { value * average / Double($0) }
        case .dollar(let value):
            return orderCount.map { value / Double($0) }
        }
    }

    var average: Double {
        return (startPrice + endPrice) / 2
    }

    var equalBtcOrders: [Order]? {

        guard let count = orderCount, let btcPortion = btcPortion, startPrice != endPrice else {
            return nil
        }
        return Array(0..<count).map {
            let offset = Double($0) * interval
            let price = startPrice + (startPrice > endPrice ? -offset : offset)
            return Order(price: price.roundedInt, btcAmount: btcPortion, dollarAmount: price * btcPortion)
        }
    }

    var equalDollarOrders: [Order]? {

        guard let count = orderCount, let dollarPortion = dollarPortion, startPrice != endPrice else {
            return nil
        }
        return Array(0..<count).map {
            let offset = Double($0) * interval
            let price = startPrice + (startPrice > endPrice ? -offset : offset)
            return Order(price: price.roundedInt, btcAmount: dollarPortion / price, dollarAmount: dollarPortion)
        }
    }

    var totalBtc: Double? {
        return equalBtcOrders?.reduce(0) { $0 + ($1.btcAmount ?? 0) }
    }

    var totalDollar: Double? {
        return equalDollarOrders?.reduce(0) { $0 + ($1.dollarAmount ?? 0) }
    }
}

struct Order {

    let price: Int?
    let btcAmount: Double?
    let dollarAmount: Double?
}

extension Gradient.Position {

    private enum CodingKeys: String, CodingKey {
        case btc
        case dollar
    }

    enum PostTypeCodingError: Error {
        case decoding(String)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? values.decode(Double.self, forKey: .btc) {
            self = .btc(value)
            return
        }
        if let value = try? values.decode(Double.self, forKey: .dollar) {
            self = .dollar(value)
            return
        }
        throw PostTypeCodingError.decoding("Whoops! \(dump(values))")
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .btc(let value):
            try container.encode(value, forKey: .btc)
        case .dollar(let value):
            try container.encode(value, forKey: .dollar)
        }
    }
}
