//
//  TestCell.swift
//  SwipeView
//
//  Created by 天明 on 2017/10/19.
//  Copyright © 2017年 天明. All rights reserved.
//

import UIKit

class TestCell: TMSwipeView {
    var titleLabel: UILabel!
    var line: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel = UILabel()
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
        }
        line = UIView()
        line.backgroundColor = UIColor.gray
        addSubview(line)
        line.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
