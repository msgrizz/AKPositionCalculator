//
//  GradientTableViewFooterCell.swift
//  AKPositionCalculator
//
//  Created by choukh on 2018/3/18.
//

import UIKit

class GradientTableViewFooterCell: UITableViewCell {

    @IBOutlet weak var totalDollarLabel: UILabel!
    @IBOutlet weak var totalBtcLabel: UILabel!

    func setup(gradient: Gradient?) {

        guard let gradient = gradient else {
            return
        }
        totalDollarLabel.text = (gradient.totalDollar?.roundedInt?.description).map { "\($0) 刀" }
        totalBtcLabel.text = gradient.totalBtc.map { "\($0.toString(4)) BTC" }
    }

}
