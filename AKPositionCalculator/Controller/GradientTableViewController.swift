//
//  GradientTableViewController.swift
//  AKPositionCalculator
//
//  Created by choukh on 2018/3/17.
//

import UIKit

class GradientTableViewController: UITableViewController {

    enum Segment: Int {
        case equalBtc, equalDollar
    }

    let notificationFeedback = UINotificationFeedbackGenerator()
    var gradient: Gradient?
    var segment = Segment.equalBtc

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func equalSegmentDidChange(sender: UISegmentedControl) {

        guard let segment = Segment(rawValue: sender.selectedSegmentIndex) else {
            return
        }
        self.segment = segment
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch segment {
        case .equalBtc:
            return gradient?.equalBtcOrders?.count ?? 1
        case .equalDollar:
            return gradient?.equalDollarOrders?.count ?? 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GradientTableViewCell", for: indexPath) as! GradientTableViewCell
        switch segment {
        case .equalBtc:
            cell.setup(order: gradient?.equalBtcOrders?[indexPath.row])
        case .equalDollar:
            cell.setup(order: gradient?.equalDollarOrders?[indexPath.row])
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {

        notificationFeedback.prepare()
        return indexPath
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        notificationFeedback.notificationOccurred(.success)
        tableView.deselectRow(at: indexPath, animated: true)
        view.makeToast("已复制", duration: 0.5, position: .center)
        let cell = tableView.cellForRow(at: indexPath) as! GradientTableViewCell
        UIPasteboard.general.string = cell.dollarAmountLabel.text
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let headerCell = tableView.dequeueReusableCell(withIdentifier: "GradientTableViewHeaderCell")!
        return headerCell.contentView
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        let footerCell = tableView.dequeueReusableCell(withIdentifier: "GradientTableViewFooterCell") as! GradientTableViewFooterCell
        footerCell.setup(gradient: gradient)
        return footerCell
    }

}
