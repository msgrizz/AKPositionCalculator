//
//  GradientPresetTableViewCell.swift
//  AKPositionCalculator
//
//  Created by choukh on 2018/4/8.
//

import UIKit

class GradientPresetTableViewCell: UITableViewCell {

    @IBOutlet weak var infoLabel: UILabel!

    func setup(gradient: Gradient) {
        infoLabel.text = gradient.description
    }
    
}
