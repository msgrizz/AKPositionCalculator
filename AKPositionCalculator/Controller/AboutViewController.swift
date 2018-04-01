//
//  AboutViewController.swift
//  AKPositionCalculator
//
//  Created by choukh on 2018/3/31.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var versionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        versionLabel.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }

}
