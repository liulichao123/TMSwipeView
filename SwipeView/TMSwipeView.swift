//
//  SwipeCell.swift
//  customTable
//
//  Created by 天明 on 2017/10/18.
//  Copyright © 2017年 天明. All rights reserved.
//  可以侧滑的View

import UIKit
import SnapKit

/// 可以侧滑的View的状态
enum TMSwipeStatus {
    case normal
    case swiped
}

/// 可以侧滑的View中侧滑添加的Button
class TMSwipeViewButton: UIButton {
    ///按钮宽度
    var swipeWidth: CGFloat = 0
    convenience init(title: String? = nil, image: UIImage? = nil, width: CGFloat = 0) {
        self.init(frame: CGRect.zero)
        self.swipeWidth = width
        setTitle(title, for: .normal)
        setTitleColor(UIColor.black, for: .normal)
        setImage(image, for: .normal)
    }
}

/// 可以侧滑的View
class TMSwipeView: UIView {
    
    private var uuid: String = UUID().uuidString
    private var _contentView: UIView = UIView()
    private var rightSwipeWitdh: CGFloat {
        get {
            return rightButtons.reduce(0, { (result, button) -> CGFloat in
                result + button.swipeWidth
            })
        }
    }
    var status: TMSwipeStatus = .normal
    var tapBlock: (() -> Void)?
    var rightButtons: [TMSwipeViewButton] = [] {
        didSet {
            setupRightButton()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        baseSetting()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        baseSetting()
    }
    
    override func addSubview(_ view: UIView) {
        if view == _contentView || view.classForCoder == TMSwipeViewButton.classForCoder() {
            super.addSubview(view)
        } else {
            _contentView.addSubview(view)
        }
    }
    override var backgroundColor: UIColor? {
        didSet {
            super.backgroundColor = backgroundColor
            _contentView.backgroundColor = backgroundColor
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func baseSetting() {
        _contentView.frame = self.frame
        addSubview(_contentView)
        _contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        let pan = UIPanGestureRecognizer(target: self, action: #selector(hanlePan(_:)))
        pan.delegate = self
        addGestureRecognizer(pan)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        _contentView.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(revicedRest), name: NSNotification.Name.init("__swipeViewDidTapEvent__"), object: nil)
    }
    
    func setupRightButton() {
        for item in subviews {
            if item.classForCoder == TMSwipeViewButton.classForCoder() { item.removeFromSuperview() }
        }
        rightButtons.enumerated().forEach { (i, btn) in
            insertSubview(btn, at: 0)
            btn.snp.makeConstraints({ (make) in
                if i == 0 {
                    make.right.equalToSuperview()
                } else {
                    make.right.equalTo(self.rightButtons.first!.snp.left)
                }
                make.top.bottom.equalToSuperview()
                make.width.equalTo(btn.swipeWidth)
            })
        }
    }
    
    @objc func hanlePan(_ pan: UIPanGestureRecognizer) {
        let velocityX = pan.velocity(in: self).x
        let translation = pan.translation(in: self)
        switch pan.state {
        case .began:
            NotificationCenter.default.post(name: NSNotification.Name.init("__swipeViewDidTapEvent__"), object: nil, userInfo: ["who": uuid])
            break
        case .changed:
            var x = translation.x
            let start: CGFloat = status == .normal ? 0 : -rightSwipeWitdh
            if velocityX > 0 {  // ->
                if status == .normal {
                    if x >= 0 {
                        x = 0
                        //将滑动位置重置为 0，防止多划的x对反向滑动产生影响
                        pan.setTranslation(CGPoint.init(x: x, y: translation.y), in: self)
                    }
                } else {
                    if x >= rightSwipeWitdh {
                        x = rightSwipeWitdh
                        pan.setTranslation(CGPoint.init(x: x, y: translation.y), in: self)
                    }
                }
            } else {            // <-
                if status == .normal {
                    if x <= -rightSwipeWitdh {
                        x = -rightSwipeWitdh
                        pan.setTranslation(CGPoint.init(x: x, y: translation.y), in: self)
                    }
                } else {
                    if x <= 0 {
                        x = 0
                        pan.setTranslation(CGPoint.init(x: x, y: translation.y), in: self)
                    }
                }
            }
            _contentView.frame.origin.x = start + x
        default:
            UIView.animate(withDuration: 0.2, animations: {
                if self._contentView.frame.origin.x < -(self.rightSwipeWitdh/2) {
                    self._contentView.frame.origin.x = -self.rightSwipeWitdh
                } else {
                    self._contentView.frame.origin.x =  0
                }
            }, completion: { (_) in
                if self._contentView.frame.origin.x == 0 {
                    self.status = .normal
                } else {
                    self.status = .swiped
                }
            })
        }
    }
    
    @objc func revicedRest(_ notification: Notification) {
         reset()
    }
    
    func reset() {
        if _contentView.frame.origin.x == 0 && status == .normal { return }
        UIView.animate(withDuration: 0.2, animations: {
            self._contentView.frame.origin.x =  0
        }, completion: { (_) in
            self.status = .normal
        })
    }
    
    @objc func didTap() {
        reset()
        NotificationCenter.default.post(name: NSNotification.Name.init("__swipeViewDidTapEvent__"), object: nil, userInfo: ["who": uuid])
        tapBlock?()
    }
}

extension TMSwipeView: UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = pan.velocity(in: self)
            return abs(velocity.x) > abs(velocity.y)
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
}

extension TMSwipeView {
    
    /// 将所有SwipeView的状态置为normal
    class func resetNormal() {
        NotificationCenter.default.post(name: NSNotification.Name.init("__swipeViewDidTapEvent__"), object: nil, userInfo: ["who": "all"])
    }
}


