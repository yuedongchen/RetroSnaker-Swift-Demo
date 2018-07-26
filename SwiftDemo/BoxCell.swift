//
//  BoxCell.swift
//  SwiftDemo
//
//  Created by 陈越东 on 2018/7/25.
//  Copyright © 2018年 陈越东. All rights reserved.
//

import UIKit

class BoxCell: UICollectionViewCell {
    
    lazy var bodyView : UIView = {
        let bodyView = UIView()
        bodyView.layer.cornerRadius = 7.5
        bodyView.backgroundColor = UIColor.clear
        
        return bodyView
    }()
    
//    var _bodyColor : UIColor?
//    var bodyColor : UIColor? {
//        get {
//            return _bodyColor
//        }
//        set {
//            _bodyColor = bodyColor
//            self.bodyView.backgroundColor = bodyColor
//        }
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.bodyView)
        self.bodyView.mas_makeConstraints { (make: MASConstraintMaker!) in
            make?.edges.mas_equalTo()(self);
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateBodyColor(bodyColor : UIColor) {
        self.bodyView.backgroundColor = bodyColor
    }
    
}
