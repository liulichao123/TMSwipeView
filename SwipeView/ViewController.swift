//
//  ViewController.swift
//  SwipeView
//
//  Created by 天明 on 2017/10/19.
//  Copyright © 2017年 天明. All rights reserved.
//

import UIKit
import SnapKit

let kScreenWidth: CGFloat = UIScreen.main.bounds.width

class ViewController: UIViewController {
    
    var list: [TestCell] = []
    var scrollView: UIScrollView!
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.edges.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.edges.equalToSuperview()
            }
        }
        list = (0...4).map { _ in TestCell() }
        loadCells()
        
    }
    
    //布局views
    func loadCells() {
        scrollView.contentSize = CGSize(width: kScreenWidth, height: CGFloat(list.count * 60 + 20))
        var last: TestCell? = nil
        list.enumerated().forEach { (i, cell) in
            scrollView.addSubview(cell)
            let height: CGFloat = self.selectedIndex == i ? 80 : 60
            if let last = last {
                cell.snp.makeConstraints({ (make) in
                    make.width.equalTo(kScreenWidth)
                    make.height.equalTo(height)
                    make.left.equalToSuperview()
                    make.top.equalTo(last.snp.bottom)
                })
            } else {
                cell.snp.makeConstraints({ (make) in
                    make.width.equalTo(kScreenWidth)
                    make.height.equalTo(height)
                    make.left.top.equalToSuperview()
                })
            }
            cell.titleLabel.text = "第\(i)项"
            cell.tag = i
            //------基本设置---------
            cell.tapBlock = { [unowned self] in
                self.didClickCell(cell)
            }
            let btn1 = TMSwipeViewButton.init(title: "哈哈", width: 50)
            btn1.backgroundColor = .red
            let btn2 = TMSwipeViewButton.init(title: "啦啦啦", width: 80)
            btn2.backgroundColor = .blue
            cell.rightButtons = [btn1, btn2]
            //
            last = cell
        }
    }
    
    @objc func didClickCell(_ cell: TestCell) {
        let last: TestCell = list[selectedIndex]
        //高度变化动画
        UIView.animate(withDuration: 0.1, animations: {
            last.snp.updateConstraints { (make) in
                make.height.equalTo(60)
            }
            cell.snp.updateConstraints { (make) in
                make.height.equalTo(80)
            }
            self.view.layoutIfNeeded()
        })
        selectedIndex = cell.tag
    }
}


