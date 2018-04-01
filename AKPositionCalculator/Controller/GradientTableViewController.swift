//
//  GradientTableViewController.swift
//  AKPositionCalculator
//
//  Created by choukh on 2018/3/17.
//

import UIKit

class GradientTableViewController: UITableViewController {

    let notificationFeedback = UINotificationFeedbackGenerator()
    var gradient: Gradient?

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return gradient?.orders?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GradientTableViewCell", for: indexPath) as! GradientTableViewCell
        cell.setup(order: gradient?.orders?[indexPath.row])
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
        UIPasteboard.general.string = cell.amountLabel.text
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
