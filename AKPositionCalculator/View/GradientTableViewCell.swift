//
//  GradientTableViewCell.swift
//  AKPositionCalculator
//
//  Created by choukh on 2018/3/17.
//

import UIKit
import M13Checkbox

class GradientTableViewCell: UITableViewCell {

    weak var delegate: GradientTableViewCellDelegate?
    var indexPath: IndexPath?

    @IBOutlet weak var checkbox: M13Checkbox!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var btcAmountLabel: UILabel!
    @IBOutlet weak var dollarAmountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        checkbox.animationDuration = 0
        btcAmountLabel.isUserInteractionEnabled = true
        dollarAmountLabel.isUserInteractionEnabled = true
        priceLabel.isUserInteractionEnabled = true

        checkbox.addTarget(self, action: #selector(didTapCheckbox), for: .valueChanged)
        priceLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapPriceLabel)))
        btcAmountLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBtc)))
        dollarAmountLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapDollar)))
    }

    func setup(indexPath: IndexPath, order: Order?) {

        self.indexPath = indexPath

        guard let order = order else {
            priceLabel.text = "参数错误"
            return
        }
        priceLabel.text = order.price?.description
        btcAmountLabel.text = order.btcAmount?.toString(4)
        dollarAmountLabel.text = order.dollarAmount?.roundedInt?.description
    }

    @objc private func didTapBtc() {
        delegate?.gradientTableViewCellDidTapBtc(self)
    }

    @objc private func didTapDollar() {
        delegate?.gradientTableViewCellDidTapDollar(self)
    }

    @objc private func didTapCheckbox() {
        checkbox.checkState = checkbox.checkState == .checked ? .unchecked : .checked
        delegate?.gradientTableViewCellDidTapPrice(self)
    }

    @objc private func didTapPriceLabel() {
        delegate?.gradientTableViewCellDidTapPrice(self)
    }

}

protocol GradientTableViewCellDelegate: class {

    func gradientTableViewCellDidTapPrice(_ cell: GradientTableViewCell)
    func gradientTableViewCellDidTapBtc(_ cell: GradientTableViewCell)
    func gradientTableViewCellDidTapDollar(_ cell: GradientTableViewCell)
}


