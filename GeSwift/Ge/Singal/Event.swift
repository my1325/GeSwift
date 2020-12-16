//
//  Event.swift
//  GeSwift
//
//  Created by my on 2020/12/9.
//  Copyright © 2020 my. All rights reserved.
//

import Foundation

public enum Event<Element> {
    case next(Element)
    case error(Error)
    case completed
}
