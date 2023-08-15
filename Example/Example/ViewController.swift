//
//  ViewController.swift
//  Example
//
//  Created by mayong on 2023/8/15.
//

import UIKit
import GeSwift

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let font = UIFont.systemFont(ofSize: 16)
        let attributeString = NSMutableAttributedString(string: "a;lsdkfjlkasdfa啊冷风机阿斯利康地方收到了附件阿是戴假发塑料袋发简历；撒都发了s", attributes: [
            .font: font,
            .foregroundColor: UIColor.red
        ])
        
        let attributeString1 = NSMutableAttributedString(string: "a;l发塑料袋发简历；撒都发了s", attributes: [
            .font: font,
            .foregroundColor: UIColor.green
        ])
        
        let customViewAttachment = NSAttributedString.customViewAttachmentString({
            $0.backgroundColor = .red
            return $0
        }(UIView()), bounds: CGRect(origin: .zero, size: CGSize(width: 100, height: 20)), alignToFont: font, alignment: .center)
        
        let customViewAttachment1 = NSAttributedString.customViewAttachmentString({
            $0.backgroundColor = .blue
            return $0
        }(UIView()), bounds: CGRect(origin: .zero, size: CGSize(width: 50, height: 50)), alignToFont: font, alignment: .bottom)
        
        attributeString.append(customViewAttachment)
        attributeString.append(attributeString1)
        attributeString.append(customViewAttachment1)
        attributeString.append(attributeString1)
        
        let attributeLabel = AttributeLabel()
        attributeLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.width - 60
//        let attributeLabel = UILabel()
        attributeLabel.translatesAutoresizingMaskIntoConstraints = false
//        attributeLabel.attributedText = attributeString
        attributeLabel.attributeText = attributeString
        view.addSubview(attributeLabel)
        attributeLabel.addConstraint(inSuper: .centerY, constant: 0)
        attributeLabel.addConstraint(inSuper: .left, constant: 30)
        attributeLabel.addConstraint(inSuper: .right, constant: -30)
    }
}

