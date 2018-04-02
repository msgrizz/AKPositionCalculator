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
        calculate(.myPosition)
    }
    
    @IBAction func didTapCopyButton(sender: UIButton) {

        notificationFeedback.notificationOccurred(.success)
        view.makeToast("已复制", duration: 0.5, position: .center)
        UIPasteboard.general.string = myPositionLabel.text
    }

    @IBAction func didTapPriceButton(sender: UIButton) {

        lightImpactFeedback.impactOccurred()
        customPriceField.text = sender.titleLabel?.text
        shine(views: [customPriceField, myPositionLabel])
        calculate(.myPosition)
    }

    //MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBasicSettingView()

        let alert = UIAlertController(title: "注意", message: "本APP仅供学习期货相关知识。\n作者对因使用本APP而造成的一切损失概不负责。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "同意", style: .default, handler: { _ in alert.dismiss(animated: true, completion: nil) }))
        alert.addAction(UIAlertAction(title: "不同意", style: .cancel, handler: { _ in exit(0) }))
        present(alert, animated: true, completion: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminateNotification),
                                               name: NSNotification.Name.UIApplicationWillTerminate, object: nil)

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
        fetch()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        resetContentInset(animated: false)
        loadUserDefaults()
        calculate([.standardRatio, .myPosition])
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
            vc.gradient = Gradient(
                position:   .btc(gradientBtcField.value * customRatioField.value),
                startPrice: startPriceField.value,
                endPrice:   endPriceField.value,
                interval:   intervalField.value
            )
        } else if segue.identifier == "gradientDollar" {
            vc.gradient = Gradient(
                position:   .dollar(gradientDollarField.value * 10000 * customRatioField.value),
                startPrice: startPriceField.value,
                endPrice:   endPriceField.value,
                interval:   intervalField.value
            )
        } else if segue.identifier == "gradientPercentage" {
            vc.gradient = Gradient(
                position:   .dollar((gradientPercentageField.value / 10) * myCapitalField.value * 10000),
                startPrice: startPriceField.value,
                endPrice:   endPriceField.value,
                interval:   intervalField.value
            )
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
    }

    //MARK: View Control

    private func resetContentInset(animated: Bool = true) {

        UIView.animate(withDuration: animated ? 0.2 : 0) { [weak self] in
            self?.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self?.scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }

    private func shine(views: [UIView]) {

        UIView.animate(withDuration: 0.1, animations: {
            views.forEach { $0.backgroundColor = UIColor.green.withAlphaComponent(0.3) }
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                views.forEach { $0.backgroundColor = .white }
            }
        })
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
    }

}

extension ViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

        let keyboardHeight = CGFloat(350)
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
    }
}




