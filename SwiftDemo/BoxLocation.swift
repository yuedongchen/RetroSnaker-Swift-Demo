//
//  BoxLocation.swift
//  SwiftDemo
//
//  Created by 陈越东 on 2018/7/25.
//  Copyright © 2018年 陈越东. All rights reserved.
//

import UIKit

class BoxLocation: NSObject {
    
    var x : NSInteger?
    var y : NSInteger?
    var lineNumber : NSInteger?
    var index: NSInteger {
        get {
            return (self.y! - 1) * self.lineNumber! + self.x! - 1
        }
    }
    
    init(x: NSInteger, y: NSInteger, lineNumber: NSInteger) {
        super.init()
        self.x = x
        self.y = y
        self.lineNumber = lineNumber
    }

}

