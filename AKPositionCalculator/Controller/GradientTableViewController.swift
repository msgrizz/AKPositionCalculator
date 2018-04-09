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
    var unwindBtc: Double? = 0
    var unwindPrice: Double? = 0
    var gradient: Gradient?
    private var segment = Segment.equalBtc
    fileprivate var priceCheckedIndexPaths = [IndexPath]()

    @IBAction func equalSegmentDidChange(sender: UISegmentedControl) {

        guard let segment = Segment(rawValue: sender.selectedSegmentIndex) else {
            return
        }
        self.segment = segment
        tableView.reloadData()
    }

    @IBAction func didTapReversePriceButton(sender: UIButton) {

        gradient?.swapPrice()
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
        cell.delegate = self
        switch segment {
        case .equalBtc:
            cell.setup(indexPath: indexPath, order: gradient?.equalBtcOrders?[indexPath.row])
        case .equalDollar:
            cell.setup(indexPath: indexPath, order: gradient?.equalDollarOrders?[indexPath.row])
        }
        cell.checkbox.setCheckState(priceCheckedIndexPaths.contains(indexPath) ? .checked : .unchecked, animated: false)
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let header = tableView.dequeueReusableCell(withIdentifier: "GradientTableViewHeaderCell") as! GradientTableViewHeaderCell
        return header
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        let footer = tableView.dequeueReusableCell(withIdentifier: "GradientTableViewFooterCell") as! GradientTableViewFooterCell
        let n = tableView.numberOfRows(inSection: 0) - priceCheckedIndexPaths.count
        switch segment {
        case .equalBtc:
            guard let orders = gradient?.equalBtcOrders?.dropLast(n) else {
                return footer
            }
            unwindBtc = orders.reduce(0) { $0 + ($1.btcAmount ?? 0) }
            unwindPrice = orders.count == 0 ? gradient?.average
                : orders.compactMap { $0.price }.reduce(0) { $0 + Double($1) } / Double(orders.count)
            footer.setup(gradient: gradient,
                             averagePrice: unwindPrice,
                             dealedBtcAmount: unwindBtc,
                             dealedDollarAmount: orders.reduce(0) { $0 + ($1.dollarAmount ?? 0) })
        case .equalDollar:
            guard let orders = gradient?.equalDollarOrders?.dropLast(n) else {
                return footer
            }
            unwindBtc = orders.reduce(0) { $0 + ($1.btcAmount ?? 0) }
            unwindPrice = orders.count == 0 ? gradient?.average
                : orders.compactMap { $0.price }.reduce(0) { $0 + Double($1) }  / Double(orders.count)
            footer.setup(gradient: gradient,
                             averagePrice: unwindPrice,
                             dealedBtcAmount: unwindBtc,
                             dealedDollarAmount: orders.reduce(0) { $0 + ($1.dollarAmount ?? 0) })
        }
        return footer
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 80
    }

}

extension GradientTableViewController: GradientTableViewCellDelegate {

    func gradientTableViewCellDidTapPrice(_ cell: GradientTableViewCell) {

        switch cell.checkbox.checkState {
        case .checked where cell.indexPath == priceCheckedIndexPaths.last:
            priceCheckedIndexPaths = []
        default:
            priceCheckedIndexPaths = (cell.indexPath.map { Array(0...$0.row) }?.map { IndexPath(row: $0, section: 0) }) ?? []
        }
        tableView.reloadData()
    }

    func gradientTableViewCellDidTapBtc(_ cell: GradientTableViewCell) {

        notificationFeedback.prepare()
        notificationFeedback.notificationOccurred(.success)
        tableView.makeToast("已复制 \(cell.btcAmountLabel.text ?? "")", duration: 0.5, position: .center)
        UIPasteboard.general.string = cell.btcAmountLabel.text
    }

    func gradientTableViewCellDidTapDollar(_ cell: GradientTableViewCell) {

        notificationFeedback.prepare()
        notificationFeedback.notificationOccurred(.success)
        tableView.makeToast("已复制 \(cell.dollarAmountLabel.text ?? "")", duration: 0.5, position: .center)
        UIPasteboard.general.string = cell.dollarAmountLabel.text
    }
}
