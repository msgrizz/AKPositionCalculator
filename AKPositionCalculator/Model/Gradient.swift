//
//  GradientParam.swift
//  AKPositionCalculator
//
//  Created by choukh on 2018/3/17.
//

import Foundation

struct Gradient {

    enum Position {
        case btc(Double)
        case dollar(Double)
    }

    let position: Position
    let startPrice: Double
    let endPrice: Double
    let interval: Double

    private var orderCount: Int? {
        return Int(exactly: ceil(abs(startPrice - endPrice) / interval)).map { $0 + 1 }
    }

    private var portion: Double? {
        switch position {
        case .btc(let value):
            return orderCount.map { value / Double($0) }
        case .dollar(let value):
            return orderCount.map { (value / average) / Double($0) }
        }
    }

    var average: Double {
        return (startPrice + endPrice) / 2
    }

    var orders: [Order]? {

        guard let count = orderCount, let portion = portion, startPrice != endPrice else {
            return nil
        }
        return Array(0..<count).map {
            let offset = Double($0) * interval
            let price = startPrice + (startPrice > endPrice ? -offset : offset)
            return Order(price: price.roundedInt, amount: (price * portion).roundedInt)
        }
    }

    var total: Int? {
        return orders?.reduce(0) { $0 + ($1.amount ?? 0) }
    }
}

struct Order {

    let price: Int?
    let amount: Int?
}
