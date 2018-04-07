//
//  Bool.swift
//  AKPositionCalculator
//
//  Created by choukh on 2018/4/5.
//

import Foundation

extension Bool {

    var reversed: Bool {
        return !self
    }

    mutating func reverse() {
        self = !self
    }
}
