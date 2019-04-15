//
//  LLImageCompleteButton.swift
//  LLImagePicker
//
//  Created by LOLITA on 2019/4/14.
//  Copyright © 2019 LOLITA0164. All rights reserved.
//

import UIKit

// 照片选中页面下方工具栏的完成按钮
class LLImageCompleteButton: UIView {
    // 已选照片数量
    var numLabel:UILabel!
    // 按钮标题标签
    var titleLabel:UILabel!
    
    // 按钮标题的默认尺寸
    let defaultFrame = CGRect.init(origin: .zero, size: CGSize.init(width: 70, height: 20))
    
    // 文字颜色
    let titleColor = UIColor(red: 0x09/255, green: 0xbb/255, blue: 0x07/255, alpha: 1)
    
    // 点击手势
    var tapSingle:UITapGestureRecognizer?
    
    // 设置数量
    var num:Int = 0 {
        didSet {
            if num == 0 {
                numLabel.isHidden = true
            } else {
                numLabel.isHidden = false
                numLabel.text = String(num)
                // 进行动画
                self.playAnimate()
            }
        }
    }
    
    // 是否可用
    var isEnabled:Bool = true {
        didSet {
            self.tapSingle?.isEnabled = isEnabled
            if isEnabled {
                self.titleLabel.textColor = self.titleColor
            } else {
                self.titleLabel.textColor = UIColor.gray
            }
        }
    }
    
    
    init(){
        super.init(frame:defaultFrame)
        
        // 已选照片数量标签初始化
        self.numLabel = UILabel(frame:CGRect(x: 0 , y: 0 , width: 20, height: 20))
        self.numLabel.backgroundColor = self.titleColor
        self.numLabel.layer.cornerRadius = 10
        self.numLabel.layer.masksToBounds = true
        self.numLabel.textAlignment = .center
        self.numLabel.font = UIFont.systemFont(ofSize: 15)
        self.numLabel.textColor = UIColor.white
        self.numLabel.adjustsFontSizeToFitWidth = true
        self.numLabel.isHidden = true
        self.addSubview(self.numLabel)
        
        //按钮标题标签初始化
        self.titleLabel = UILabel(frame:CGRect(x: 20 ,
                                               y: 0 ,
                                               width: self.defaultFrame.width - 20,
                                               height: 20))
        self.titleLabel.text = "完成"
        self.titleLabel.textAlignment = .center
        self.titleLabel.font = UIFont.systemFont(ofSize: 17)
        self.titleLabel.textColor = self.titleColor
        self.addSubview(self.titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // 播放动画
    func playAnimate() {
        //从小变大，且有弹性效果
        self.numLabel.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5, options: UIView.AnimationOptions(),
                       animations: {
                        self.numLabel.transform = CGAffineTransform.identity
        }, completion: nil)
    }

    // 添加单击事件
    func addTarget(target: Any?, action: Selector?) {
        //单击监听
        self.tapSingle = UITapGestureRecognizer(target:target,action:action)
        self.tapSingle!.numberOfTapsRequired = 1
        self.tapSingle!.numberOfTouchesRequired = 1
        self.addGestureRecognizer(self.tapSingle!)
    }
}
