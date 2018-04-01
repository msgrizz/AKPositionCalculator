//
//  CalculationOptions.swift
//  AKPositionCalculator
//
//  Created by choukh on 2018/3/17.
//

import Foundation

struct CalculationOptions: OptionSet {
    let rawValue: Int
    
    static let standardRatio    = CalculationOptions(rawValue: 1 << 0)
    static let customRatio      = CalculationOptions(rawValue: 1 << 1)
    static let myPosition       = CalculationOptions(rawValue: 1 << 2)

    static let all: CalculationOptions = [.standardRatio, .customRatio, .myPosition]
}
