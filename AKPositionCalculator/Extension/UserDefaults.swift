//
//  UserDefaults.swift
//  AKPositionCalculator
//
//  Created by choukh on 2018/3/17.
//

import Foundation

extension UserDefaults {

    static func setDefaultValues() {

        UserDefaults.standard.set(true,             forKey: UserDefaultsKey.doesShowSetting)
        UserDefaults.standard.set(Double(300),      forKey: UserDefaultsKey.akCapital)
        UserDefaults.standard.set(Double(100),      forKey: UserDefaultsKey.myCapital)
        UserDefaults.standard.set(Double(0.33333),  forKey: UserDefaultsKey.customRatio)
        UserDefaults.standard.set(Double(1),        forKey: UserDefaultsKey.multiple)
        UserDefaults.standard.set(Double(8000),     forKey: UserDefaultsKey.customPrice)
        UserDefaults.standard.set(Double(5),        forKey: UserDefaultsKey.akPosition)
        UserDefaults.standard.set(Double(100),      forKey: UserDefaultsKey.gradientBtc)
        UserDefaults.standard.set(Double(100),      forKey: UserDefaultsKey.gradientDollar)
        UserDefaults.standard.set(Double(2),        forKey: UserDefaultsKey.gradientPercentage)
        UserDefaults.standard.set(Double(9000),     forKey: UserDefaultsKey.startPrice)
        UserDefaults.standard.set(Double(8000),     forKey: UserDefaultsKey.endPrice)
        UserDefaults.standard.set(Double(100),      forKey: UserDefaultsKey.interval)
    }
}
