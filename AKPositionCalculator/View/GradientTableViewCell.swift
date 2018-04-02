//
//  GradientTableViewCell.swift
//  AKPositionCalculator
//
//  Created by choukh on 2018/3/17.
//

import UIKit

class GradientTableViewCell: UITableViewCell {

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var btcAmountLabel: UILabel!
    @IBOutlet weak var dollarAmountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setup(order: Order?) {

        guard let order = order else {
            priceLabel.text = "参数错误"
            return
        }
        priceLabel.text = order.price?.description
        btcAmountLabel.text = order.btcAmount?.toString(4)
        dollarAmountLabel.text = order.dollarAmount?.roundedInt?.description
    }

}
