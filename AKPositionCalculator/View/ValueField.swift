//
//  ValueField.swift
//  AKPositionCalculator
//
//  Created by choukh on 2018/3/16.
//

import UIKit

class ValueField: UITextField {
    
    var doneClosure: (() -> Void)?
    var cancelClosure: (() -> Void)?
    
    var value: Double {
        get {
            return Double(text ?? "") ?? 0
        }
        set {
            previousText = text
            text = newValue.string
        }
    }
    private var previousText: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        delegate = self
    }

    func clear() {

        previousText = text
        text = nil
    }

    func restore() {
        text = previousText
    }

    func addDoneCancelToolbar(onDone: (() -> Void)? = nil, onCancel: (() -> Void)? = nil) {
        
        doneClosure = onDone
        cancelClosure = onCancel
        
        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(didTapCancelButton)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "确定", style: .done, target: self, action: #selector(didTapDoneButton))
        ]
        toolbar.sizeToFit()
        inputAccessoryView = toolbar
    }
    
    @objc private func didTapDoneButton() {
        
        guard let value = Double(text ?? "") else {
            return
        }
        self.resignFirstResponder()
        self.value = value
        doneClosure?()
    }
    
    @objc private func didTapCancelButton() {
        self.resignFirstResponder()
        
        text = previousText
        cancelClosure?()
    }
}

extension ValueField: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        previousText = text
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        doneClosure?()
    }
}
