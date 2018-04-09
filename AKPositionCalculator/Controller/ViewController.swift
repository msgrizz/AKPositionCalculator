//
//  ViewController.swift
//  AKPositionCalculator
//
//  Created by choukh on 2018/3/16.
//

import UIKit
import Moya
import RxMoya
import RxSwift
import ToastSwiftFramework

class ViewController: UIViewController {

    //MARK: - Properties

    private let notificationFeedback = UINotificationFeedbackGenerator()
    private let lightImpactFeedback = UIImpactFeedbackGenerator(style: .light)
    private let bitstamp = MoyaProvider<Bitstamp>()
    private let bitfinex = MoyaProvider<Bitfinex>()
    private let bitmex = MoyaProvider<Bitmex>()
    private let disposeBag = DisposeBag()
    private var unwindClosure: (() -> Void)?
    fileprivate var presets = [Gradient]()

    //MARK: - IBOutlet

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var akCapitalField: ValueField!
    @IBOutlet weak var myCapitalField: ValueField!
    @IBOutlet weak var standardRatioLabel: UILabel!
    @IBOutlet weak var multipleField: ValueField!
    @IBOutlet weak var customRatioField: ValueField!
    @IBOutlet weak var akPositionField: ValueField!
    @IBOutlet weak var customPriceField: ValueField!
    @IBOutlet weak var myPositionBtcLabel: UILabel!
    @IBOutlet weak var myPositionLabel: UILabel!
    @IBOutlet weak var customBtcField: ValueField!
    @IBOutlet weak var customPositionLabel: UILabel!
    @IBOutlet weak var startPriceField: ValueField!
    @IBOutlet weak var endPriceField: ValueField!
    @IBOutlet weak var intervalField: ValueField!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var fundingRateLabel: UILabel!
    @IBOutlet weak var indicativeFundingRateLabel: UILabel!
    @IBOutlet weak var bitstampButton: UIButton!
    @IBOutlet weak var bitfinexButton: UIButton!
    @IBOutlet weak var bitmexSwapButton: UIButton!
    @IBOutlet weak var bitmexMonthlyButton: UIButton!
    @IBOutlet weak var bitmexBiquarterlyButton: UIButton!
    @IBOutlet weak var gradientBtcField: ValueField!
    @IBOutlet weak var gradientDollarField: ValueField!
    @IBOutlet weak var gradientPercentageField: ValueField!
    @IBOutlet weak var basicSettingButton:  UIButton!
    @IBOutlet weak var basicSettingViewHeight: NSLayoutConstraint!
    @IBOutlet weak var presetTableView: UITableView!
    @IBOutlet weak var presetTableViewHeight: NSLayoutConstraint!

    //MARK: - IBAction

    @IBAction func didTapBasicSettingButton(sender: UIButton) {

        toggleBasicSettingView()
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: { _ in
            sender.isUserInteractionEnabled = true
        })
    }

    @IBAction func didTouchDownButton(sender: UIButton) {
        lightImpactFeedback.prepare()
        notificationFeedback.prepare()
    }

    @IBAction func didTapMultipleButton(sender: UIButton) {

        lightImpactFeedback.impactOccurred()
        let mutiples = [1, 1.2, 1.5, 2, 3]
        multipleField.text = mutiples[sender.tag].string
        shine(views: [myPositionBtcLabel, myPositionLabel])
        calculate([.customRatio, .myPosition])
    }
    
    @IBAction func didAddPositonButton(sender: UIButton) {

        lightImpactFeedback.impactOccurred()
        if sender.tag >= 0 {
            let adders = [5.0, 10.0]
            akPositionField.text = (akPositionField.value + adders[sender.tag]).string
        } else {
            akPositionField.text = "0"
        }
        shine(views: [myPositionBtcLabel, myPositionLabel])
        calculate(.myPosition)
    }

    @IBAction func didTapPriceButton(sender: UIButton) {

        lightImpactFeedback.impactOccurred()
        customPriceField.text = sender.titleLabel?.text
        shine(views: [customPriceField, myPositionLabel, customPositionLabel])
        calculate(.myPosition)
    }

    @IBAction func didTapMyPositionLabel() {

        notificationFeedback.notificationOccurred(.success)
        view.makeToast("已复制 \(myPositionLabel.text ?? "")", duration: 0.5, position: .center)
        UIPasteboard.general.string = myPositionLabel.text
    }

    @IBAction func didTapCustomPositionLabel() {

        notificationFeedback.notificationOccurred(.success)
        view.makeToast("已复制 \(customPositionLabel.text ?? "")", duration: 0.5, position: .center)
        UIPasteboard.general.string = customPositionLabel.text
    }

    @IBAction func didTapSavePresetButton(sender: UIButton) {

        guard let inputType = GradientInputType(rawValue: sender.tag) else {
            return
        }
        presets.append(gradientSetting(for: inputType))
        presetTableView.insertRows(at: [IndexPath(row: presets.count - 1, section: 0)], with: .automatic)
        layoutPresetTableView()
        scrollView.layoutIfNeeded()
        let bottom = scrollView.contentSize.height - scrollView.bounds.height
        bottom > 0 ? scrollView.setContentOffset(CGPoint(x: 0, y: bottom), animated: true) : ()
    }

    @IBAction func didTapReversePriceButton(sender: UIButton) {

        lightImpactFeedback.impactOccurred()
        swap(&startPriceField.text, &endPriceField.text)
        shine(views: [startPriceField, endPriceField])
    }

    //MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        showAlert()
        loadUserDefaults()
        setupBasicSettingView()
        setupFields()
        setupPresetTableView()
        fetch()

        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminateNotification),
                                               name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        resetContentInset(animated: false)
        calculate([.standardRatio, .myPosition])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        unwindClosure?()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        [gradientBtcField, gradientDollarField, gradientPercentageField, startPriceField, endPriceField, intervalField].forEach {
            $0?.resignFirstResponder()
        }
        NotificationCenter.default.removeObserver(self)
        saveUserDefaults()
    }

    @objc private func appWillTerminateNotification() {
        saveUserDefaults()
    }

    //MARK: - Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let vc = segue.destination as? GradientTableViewController else {
            return
        }
        if segue.identifier == "gradientBtc" {
            vc.gradient = gradientSetting(for: .btc)
        } else if segue.identifier == "gradientDollar" {
            vc.gradient = gradientSetting(for: .dollar)
        } else if segue.identifier == "gradientPercentage" {
            vc.gradient = gradientSetting(for: .position)
        } else if segue.identifier == "selectPreset" {
            if let cell = sender as? GradientPresetTableViewCell, let indexPath = presetTableView.indexPath(for: cell) {
                vc.gradient = presets[indexPath.row]
            }
        }
    }

    @IBAction func unwindToHere(segue: UIStoryboardSegue) {

        lightImpactFeedback.prepare()
        unwindClosure = { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.lightImpactFeedback.impactOccurred()
            if segue.identifier == "btc" {
                weakSelf.customBtcField.text = (segue.source as? GradientTableViewController)?.unwindBtc?.toString(4)
                weakSelf.calculateCustomPosition()
                weakSelf.shine(views: [weakSelf.customBtcField, weakSelf.customPositionLabel])
            } else if segue.identifier == "price" {
                weakSelf.customPriceField.text = (segue.source as? GradientTableViewController)?.unwindPrice?.roundedInt?.description
                weakSelf.calculateMyPosition()
                weakSelf.shine(views: [weakSelf.customPriceField, weakSelf.customPositionLabel, weakSelf.myPositionBtcLabel, weakSelf.myPositionLabel])
            }
            weakSelf.unwindClosure = nil
        }
    }

    //MARK: - Private Functions

    //MARK: API

    private func fetch() {

        bitstamp.rx.request(.ticker).map {
            return try? JSONDecoder().decode(Bitstamp.Ticker.self, from: $0.data)
        }.subscribe(onSuccess: { [weak self] response in
            self?.bitstampButton.setTitle(response?.last, for: .normal)
            self?.startProgress { [weak self] in self?.fetch() }
        }, onError: { [weak self] _ in
            self?.startProgress { [weak self] in self?.fetch() }
            self?.view.makeToast("交易所API连接失败", duration: 1, position: .top)
        }).disposed(by: disposeBag)

        bitfinex.rx.request(.ticker).map {
            return try? JSONDecoder().decode(Bitfinex.Ticker.self, from: $0.data)
        }.subscribe(onSuccess: { [weak self] response in
            self?.bitfinexButton.setTitle((response?.last_price).flatMap { Double($0)?.toString(2) }, for: .normal)
        }, onError: nil).disposed(by: disposeBag)

        bitmex.rx.request(.swap).map {
            return try? JSONDecoder().decode([Bitmex.Instrument].self, from: $0.data)
        }.subscribe(onSuccess: { [weak self] response in
            guard let weakSelf = self, let entity = response?.first else {
                return
            }
            weakSelf.bitmexSwapButton.setTitle(entity.lastPrice?.toString(2), for: .normal)
            weakSelf.fundingRateLabel.text = entity.fundingRate.map { $0 * 100 }?.toString(4)
            weakSelf.indicativeFundingRateLabel.text = entity.indicativeFundingRate.map { $0 * 100 }?.toString(4)
            guard let fundingRate = entity.fundingRate, let indicativeFundingRate = entity.indicativeFundingRate else {
                return
            }
            weakSelf.fundingRateLabel.textColor = fundingRate > 0 ? #colorLiteral(red: 0, green: 0.4667, blue: 0.0353, alpha: 1) : .red
            weakSelf.indicativeFundingRateLabel.textColor = indicativeFundingRate > 0 ? #colorLiteral(red: 0, green: 0.4667, blue: 0.0353, alpha: 1) : .red
        }, onError: nil).disposed(by: disposeBag)

        bitmex.rx.request(.quarterly).map {
            return try? JSONDecoder().decode([Bitmex.Instrument].self, from: $0.data)
        }.subscribe(onSuccess: { [weak self] response in
            self?.bitmexMonthlyButton.setTitle(response?.first?.lastPrice?.toString(2), for: .normal)
        }, onError: nil).disposed(by: disposeBag)

        bitmex.rx.request(.biquarterly).map {
            return try? JSONDecoder().decode([Bitmex.Instrument].self, from: $0.data)
        }.subscribe(onSuccess: { [weak self] response in
            self?.bitmexBiquarterlyButton.setTitle(response?.first?.lastPrice?.toString(2), for: .normal)
        }, onError: nil).disposed(by: disposeBag)
    }

    private func startProgress(_ n: Float = 0, task: (() -> Void)? = nil) {

        progressView.progress = n / 1000
        if n < 1000 {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(5)) { [weak self] in
                self?.startProgress(n + 1) { task?() }
            }
        } else {
            task?()
        }
    }

    //MARK: Calculation

    private func calculate(_ options: CalculationOptions) {
        
        if options.contains(.standardRatio) {
            calculateStandardRatio()
        }
        if options.contains(.customRatio) {
            calculateCustomRatio()
        }
        if options.contains(.myPosition) {
            calculateMyPosition()
        }
    }
    
    private func calculateStandardRatio() {
        
        standardRatioLabel.text = (myCapitalField.value / akCapitalField.value).toString(5)
    }
    
    private func calculateCustomRatio() {
        
        customRatioField.text = (myCapitalField.value / akCapitalField.value * multipleField.value).toString(5)
    }
    
    private func calculateMyPosition() {

        multipleField.text = standardRatioLabel.text.flatMap{ Double($0) }.map { customRatioField.value / $0 }.map { $0.toString(2) }
        myPositionLabel.text = (akPositionField.value * customRatioField.value * customPriceField.value).roundedInt?.description
        myPositionBtcLabel.text = (akPositionField.value * customRatioField.value).toString(4)

        if customBtcField.text == "" {
            customBtcField.placeholder = myPositionBtcLabel.text
            customPositionLabel.text = myPositionLabel.text
        } else {
            customPositionLabel.text = (customBtcField.value * customPriceField.value).roundedInt?.description
        }
    }

    private func calculateCustomPosition() {

        customPositionLabel.text = (customBtcField.value * customPriceField.value).roundedInt?.description
    }

    //MARK: Data Preparation

    private func gradientSetting(for type: GradientInputType) -> Gradient {

        switch type {
        case .btc:
            let value = gradientBtcField.value * customRatioField.value
            return Gradient(
                position:   .btc(value),
                startPrice: startPriceField.value,
                endPrice:   endPriceField.value,
                interval:   intervalField.value,
                description: "\(startPriceField.text ?? "")~\(endPriceField.text ?? "") (\(intervalField.text ?? "")) AK: \(gradientBtcField.text ?? "")BTC 我: \(value.roundedInt?.description ?? "")BTC (x\(customRatioField.text ?? ""))"
            )
        case .dollar:
            let value = gradientDollarField.value * customRatioField.value
            return Gradient(
                position:   .dollar(value * 10000),
                startPrice: startPriceField.value,
                endPrice:   endPriceField.value,
                interval:   intervalField.value,
                description: "\(startPriceField.text ?? "")~\(endPriceField.text ?? "") (\(intervalField.text ?? "")) AK: \(gradientDollarField.text ?? "")万刀 我: \(value.roundedInt?.description ?? "")万刀 (x\(customRatioField.text ?? ""))"
            )
        case .position:
            let value = (gradientPercentageField.value / 10) * myCapitalField.value
            return Gradient(
                position:   .dollar(value * 10000),
                startPrice: startPriceField.value,
                endPrice:   endPriceField.value,
                interval:   intervalField.value,
                description: "\(startPriceField.text ?? "")~\(endPriceField.text ?? "") (\(intervalField.text ?? "")) \(gradientPercentageField.text ?? "")成仓 (我: \(value.roundedInt?.description ?? "")万刀)"
            )
        }
    }

    //MARK: View Control

    private func showAlert() {

        let alert = UIAlertController(title: "注意", message: "所有计算结果仅供参考。实际仓位请以交易所为准。作者对因使用本APP而造成的一切损失概不负责。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "同意", style: .default, handler: { _ in alert.dismiss(animated: true, completion: nil) }))
        alert.addAction(UIAlertAction(title: "不同意", style: .cancel, handler: { _ in exit(0) }))
        present(alert, animated: true, completion: nil)
    }

    private func setupBasicSettingView() {

        let doesShowSetting = UserDefaults.standard.bool(forKey: UserDefaultsKey.doesShowSetting)
        basicSettingViewHeight.constant = doesShowSetting ? 172 : 0
        basicSettingButton.setTitle(doesShowSetting ? "隐藏设置" : "展开设置", for: .normal)
    }

    private func toggleBasicSettingView() {

        let doesShowSetting = UserDefaults.standard.bool(forKey: UserDefaultsKey.doesShowSetting)
        UserDefaults.standard.set(!doesShowSetting, forKey: UserDefaultsKey.doesShowSetting)
        setupBasicSettingView()
    }

    private func setupFields() {

        customBtcField.delegate = self
        customPriceField.delegate = self

        [akCapitalField, myCapitalField].forEach {
            $0?.addDoneCancelToolbar(onDone: { [weak self] in self?.calculate(.all) })
        }
        [multipleField].forEach {
            $0?.addDoneCancelToolbar(onDone: { [weak self] in self?.calculate([.customRatio, .myPosition]) })
        }
        [customRatioField, akPositionField, customPriceField].forEach {
            $0?.addDoneCancelToolbar(onDone: { [weak self] in self?.calculate(.myPosition) })
        }
        [gradientBtcField, gradientDollarField, gradientPercentageField, startPriceField, endPriceField, intervalField].forEach {
            $0?.addDoneCancelToolbar(
                onDone: { [weak self] in self?.resetContentInset() },
                onCancel: { [weak self] in self?.resetContentInset() }
            )
            $0?.delegate = self
        }
        customBtcField.addDoneCancelToolbar(
            onDone: { [weak self] in self?.calculateCustomPosition() },
            onCancel: { [weak self] in self?.customBtcField.restore() })
        customPriceField.cancelClosure = { [weak self] in self?.customPriceField.restore() }
    }

    private func resetContentInset(animated: Bool = true) {

        UIView.animate(withDuration: animated ? 0.2 : 0) { [weak self] in
            self?.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self?.scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }

    private func shine(views: [UIView]) {

        UIView.animateKeyframes(
            withDuration: 0.5, delay: 0, options: [.beginFromCurrentState, .calculationModeLinear],
            animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1, animations: { views.forEach {
                    if $0 is UILabel {
                        $0.layer.backgroundColor = #colorLiteral(red: 0.549, green: 0.8941, blue: 1, alpha: 1)
                    } else {
                        $0.backgroundColor = #colorLiteral(red: 0.549, green: 0.8941, blue: 1, alpha: 1)
                    }
                }})
                UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.4, animations: { views.forEach {
                    if $0 is UILabel {
                        $0.layer.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    } else {
                        $0.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    }
                }})
            }, completion: nil
        )
    }

    private func setupPresetTableView() {

        presetTableView.dataSource = self
        presetTableView.delegate = self
        layoutPresetTableView()
    }

    private func layoutPresetTableView() {

        presetTableView.layoutIfNeeded()
        presetTableViewHeight.constant = presetTableView.contentSize.height
    }

    //MARK: UserDefaults

    private func saveUserDefaults() {

        UserDefaults.standard.set(akCapitalField.value,         forKey: UserDefaultsKey.akCapital)
        UserDefaults.standard.set(myCapitalField.value,         forKey: UserDefaultsKey.myCapital)
        UserDefaults.standard.set(customRatioField.value,       forKey: UserDefaultsKey.customRatio)
        UserDefaults.standard.set(multipleField.value,          forKey: UserDefaultsKey.multiple)
        UserDefaults.standard.set(customPriceField.value,       forKey: UserDefaultsKey.customPrice)
        UserDefaults.standard.set(akPositionField.value,        forKey: UserDefaultsKey.akPosition)
        UserDefaults.standard.set(gradientBtcField.value,       forKey: UserDefaultsKey.gradientBtc)
        UserDefaults.standard.set(gradientDollarField.value,    forKey: UserDefaultsKey.gradientDollar)
        UserDefaults.standard.set(gradientPercentageField.value,forKey: UserDefaultsKey.gradientPercentage)
        UserDefaults.standard.set(startPriceField.value,        forKey: UserDefaultsKey.startPrice)
        UserDefaults.standard.set(endPriceField.value,          forKey: UserDefaultsKey.endPrice)
        UserDefaults.standard.set(intervalField.value,          forKey: UserDefaultsKey.interval)

        if let presetData = try? JSONEncoder().encode(presets) {
            UserDefaults.standard.set(presetData, forKey: UserDefaultsKey.gradientPreset)
        }
    }

    private func loadUserDefaults() {

        akCapitalField.value            = UserDefaults.standard.double(forKey: UserDefaultsKey.akCapital)
        myCapitalField.value            = UserDefaults.standard.double(forKey: UserDefaultsKey.myCapital)
        customRatioField.value          = UserDefaults.standard.double(forKey: UserDefaultsKey.customRatio)
        multipleField.value             = UserDefaults.standard.double(forKey: UserDefaultsKey.multiple)
        customPriceField.value          = UserDefaults.standard.double(forKey: UserDefaultsKey.customPrice)
        akPositionField.value           = UserDefaults.standard.double(forKey: UserDefaultsKey.akPosition)
        gradientBtcField.value          = UserDefaults.standard.double(forKey: UserDefaultsKey.gradientBtc)
        gradientDollarField.value       = UserDefaults.standard.double(forKey: UserDefaultsKey.gradientDollar)
        gradientPercentageField.value   = UserDefaults.standard.double(forKey: UserDefaultsKey.gradientPercentage)
        startPriceField.value           = UserDefaults.standard.double(forKey: UserDefaultsKey.startPrice)
        endPriceField.value             = UserDefaults.standard.double(forKey: UserDefaultsKey.endPrice)
        intervalField.value             = UserDefaults.standard.double(forKey: UserDefaultsKey.interval)

        if let presetData = UserDefaults.standard.value(forKey: UserDefaultsKey.gradientPreset) as? Data {
            presets = (try? JSONDecoder().decode([Gradient].self, from: presetData)) ?? []
        }
    }

}

extension ViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {

        if let textField = textField as? ValueField, textField  == customBtcField || textField == customPriceField{
            textField.clear()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

        let keyboardHeight = CGFloat(350)
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
    }
}

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "GradientPresetTableViewCell", for: indexPath) as! GradientPresetTableViewCell
        cell.setup(gradient: presets[indexPath.row])
        return cell
    }
}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let delete = UIContextualAction(style: .normal, title: "删除", handler: { [weak self] action, view, success in
            guard let weakSelf = self else {
                success(false)
                return
            }
            weakSelf.presets.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            weakSelf.layoutPresetTableView()
            UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveLinear, animations: { [weak self] in
                self?.scrollView.layoutIfNeeded()
            }, completion: nil)
            success(true)
        })
        delete.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [delete])
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
