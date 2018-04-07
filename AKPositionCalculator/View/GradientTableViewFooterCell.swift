//
//  GradientTableViewFooterCell.swift
//  AKPositionCalculator
//
//  Created by choukh on 2018/3/18.
//

import UIKit

class GradientTableViewFooterCell: UITableViewCell {

    @IBOutlet weak var averagePriceLabel: UILabel!
    @IBOutlet weak var totalDollarLabel: UILabel!
    @IBOutlet weak var totalBtcLabel: UILabel!
    @IBOutlet weak var dealedDollarLabel: UILabel!
    @IBOutlet weak var dealedBtcButton: UIButton!

    func setup(gradient: Gradient?, dealedBtcAmount: Double?, dealedDollarAmount: Double?) {

        guard let gradient = gradient else {
            return
        }
        averagePriceLabel.text = (gradient.average.roundedInt?.description).map { "\($0) 刀" }
        dealedBtcButton.setTitle(dealedBtcAmount.map {"\($0.toString(4)) BTC"}, for: .normal)
        dealedDollarLabel.text = (dealedDollarAmount?.roundedInt?.description).map {"\($0) 刀"}
        totalBtcLabel.text = gradient.totalBtc.map { "\($0.toString(4)) BTC" }
        totalDollarLabel.text = (gradient.totalDollar?.roundedInt?.description).map { "\($0) 刀" }
    }

}
