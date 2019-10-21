//
//  Text.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/10/18.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit


open class Text: View {
    
        
//    override func layout() -> UIView {
//        return UILabel()
//    }
//    
    var text: String? 
    
    var textColor: UIColor = UIColor.black
    
    var font: UIFont = UIFont.systemFont(ofSize: 17)
    
    var textAlignment: NSTextAlignment = .left
    
    var numberOfLines: Int = 1
}
