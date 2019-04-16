//
//  LLExtension.swift
//  LLImagePicker
//
//  Created by LOLITA0164 on 2019/4/16.
//  Copyright © 2019年 LOLITA0164. All rights reserved.
//

import Foundation
import UIKit

// MARK:- 添加提示
var key_tip = "key_tip"
/// 添加提示
extension UIView {
    // 视图数组
    var tipViews:[UIView]? {
        set {
            objc_setAssociatedObject(self, &key_tip, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            var tmp = objc_getAssociatedObject(self, &key_tip) as? [UIView]
            if tmp == nil {
                tmp = [UIView]()
            }
            return tmp
        }
    }
    
    /// 添加提示视图
    func addTipView(title:String?, des:String?, actionTitle:String?, target: Any?, action: Selector?) {
        // 先移除可能存储的视图
        self.removeTipView()
        // 背景视图，用来
        let bgView = UIView()
        self.addSubview(bgView)
        // 标题标签
        let titleLabel = self.getLabel(title: title, font: UIFont.boldSystemFont(ofSize: 18), color: UIColor.black)
        bgView.addSubview(titleLabel)
        // 描述标签
        let desLabel = self.getLabel(title: des, font: UIFont.systemFont(ofSize: 17), color: UIColor.gray)
        bgView.addSubview(desLabel)
        // 按钮
        let btn = UIButton.init()
        btn.setTitle(actionTitle, for: .normal)
        if let action = action {
            btn.addTarget(target, action: action, for: .touchUpInside)
        }
        btn.setTitleColor(LLImageManager.shared.themeColor, for: .normal)
        btn.titleLabel?.font = titleLabel.font
        bgView.addSubview(btn)
        // 添加约束
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        let space = (des == nil || des == "") ? 0 : 15
        desLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(space)
            make.bottom.equalTo(btn.snp.top).offset(-space)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        btn.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            if actionTitle == nil || actionTitle == "" {
                make.height.equalTo(0)
            }
        }
        self.addSubview(bgView)
        bgView.snp.makeConstraints { [weak self] (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(titleLabel.snp.top)
            make.bottom.equalTo(btn.snp.bottom)
            make.center.equalTo(self!.snp.center)
        }
        self.tipViews?.append(bgView)
    }
    
    /// 移除提示视图
    func removeTipView() {
        if let views = self.tipViews {
            for item in views {
                item.removeFromSuperview()
            }
        }
        self.tipViews?.removeAll()
    }
    
    private func getLabel(title:String?, font:UIFont, color:UIColor) -> UILabel {
        let tmpLabel = UILabel()
        tmpLabel.text = title
        tmpLabel.textColor = color
        tmpLabel.font = font
        tmpLabel.textAlignment = .center
        tmpLabel.numberOfLines = 0
        return tmpLabel
    }
}
