//
//  InpuFieldViewController.swift
//  GeSwift
//
//  Created by my on 2021/1/26.
//  Copyright © 2021 my. All rights reserved.
//

import UIKit

internal final class InputFieldStyleNone: InputFieldStyleProtocol {
    var borderStyle: BorderStyle {
        return .none
    }
}

internal final class InputFieldStyleUnderline: InputFieldStyleProtocol {
    var borderStyle: BorderStyle {
        return .underline
    }
}

internal final class InputFieldStyleBox: InputFieldStyleProtocol {
    var borderStyle: BorderStyle {
        return .box
    }
}

internal final class InputFieldViewController: BaseViewController {
    
    private lazy var stackView: UIStackView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.alignment = .fill
        self.view.addSubview($0)
        $0.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(180)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        return $0
    }(UIStackView())
    
    private lazy var inputFieldStyleNone: InputField = {
        $0.delegate = self
        $0.keyboardType = .numberPad
        $0.textColor = UIColor.red
        $0.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        $0.isSecureTextEntry = false
        $0.style = InputFieldStyleNone()
        $0.limitCount = 11
        $0.backgroundColor = UIColor.green
        self.stackView.addArrangedSubview($0)
        return $0
    }(InputField())
    
    private lazy var inputFieldStyleBox: InputField = {
        $0.delegate = self
        $0.keyboardType = .default
        $0.returnKeyType = .continue
        $0.textColor = UIColor.blue
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        $0.isSecureTextEntry = true
        $0.style = InputFieldStyleBox()
//        $0.backgroundColor = UIColor.red
        self.stackView.addArrangedSubview($0)
        return $0
    }(InputField())

    private lazy var inputFieldStyleUnderline: InputField = {
        $0.delegate = self
        $0.keyboardType = .emailAddress
        $0.textColor = UIColor.black
        $0.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        $0.isSecureTextEntry = false
        $0.style = InputFieldStyleUnderline()
        $0.backgroundColor = UIColor.yellow
        self.stackView.addArrangedSubview($0)
        return $0
    }(InputField())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputFieldStyleNone.reloadData()
        inputFieldStyleBox.reloadData()
        inputFieldStyleUnderline.reloadData()
    }
}

extension InputFieldViewController: InputFieldDelegate {
    
    func inputField(_ inputField: InputField, textDidChange text: String?) {
        Logger.normal.log(text ?? "")
    }
}
