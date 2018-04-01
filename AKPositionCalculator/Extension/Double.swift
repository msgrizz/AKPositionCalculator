//
//  Double.swift
//  AKPositionCalculator
//
//  Created by choukh on 2018/3/17.
//

import UIKit

extension Double {

    var roundedInt: Int? {
        return Int(exactly: self.rounded())
    }

    var string: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }

    func toString(_ n: Int) -> String {
        return String(format: "%.\(n)f", self)
    }
}
