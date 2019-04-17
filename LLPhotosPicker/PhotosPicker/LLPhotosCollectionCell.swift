//
//  LLPhotosCollectionCell.swift
//  LLPhotosPicker
//
//  Created by LOLITA on 2019/4/14.
//  Copyright © 2019 LOLITA0164. All rights reserved.
//

import UIKit

// 图片缩略图集合页面的单元格
class LLPhotosCollectionCell: UICollectionViewCell {
    // 显示缩略图
    var imageView: UIImageView!
    // 显示选中状态的图标
    var selectedIconImageView: UIImageView!
    // 显示 时长/GIF 等标识符
    var subLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 初始化缩略图
        self.imageView = UIImageView()
        self.addSubview(self.imageView)
        // 初始化选中图标
        self.selectedIconImageView = UIImageView()
        self.addSubview(self.selectedIconImageView)
        // 初始化标识符标签
        self.subLabel = UILabel.init()
        self.subLabel.textColor = UIColor.white
        self.subLabel.textAlignment = .right
        self.subLabel.font = UIFont.boldSystemFont(ofSize: 16)
        self.addSubview(self.subLabel)
        
        // 设置约束
        self.imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.selectedIconImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.width.height.equalTo(25)
        }
        self.subLabel.snp.makeConstraints { (make) in
            make.bottom.right.equalToSuperview().offset(-5)
            make.left.equalToSuperview().offset(5)
            make.height.equalTo(15)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // 设置是否选中
    open override var isSelected: Bool {
        didSet {
            let icon = isSelected ? "ll_image_selected" : "ll_image_not_selected"
            self.selectedIconImageView.image = UIImage.init(named: icon)
        }
    }
    
    // 播放动画，是否选中的图片改变时使用
    func playAnimate() {
        // 图标先缩小，再放大
        UIView.animateKeyframes(withDuration: 0.4, delay: 0, options: .allowUserInteraction, animations: {
            // 缩小
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2, animations: {
                self.selectedIconImageView.transform = CGAffineTransform.init(scaleX: 0.7, y: 0.7)
            })
            // 放大
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.4, animations: {
                self.selectedIconImageView.transform = CGAffineTransform.identity
            })
        }, completion: nil)
    }
}
