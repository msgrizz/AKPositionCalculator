//
//  GradientTableViewFooterCell.swift
//  AKPositionCalculator
//
//  Created by choukh on 2018/3/18.
//

import UIKit

class GradientTableViewFooterCell: UITableViewCell {

    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalBtcLabel: UILabel!

    func setup(gradient: Gradient?) {

        guard let gradient = gradient else {
            return
        }
        totalLabel.text = (gradient.total?.description).map { "\($0) 刀" }
        totalBtcLabel.text = gradient.total.map { Double($0) / gradient.average }.map { "\($0.toString(4)) BTC" }
    }

}
