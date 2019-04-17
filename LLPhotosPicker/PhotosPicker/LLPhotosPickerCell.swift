//
//  LLPhotosPickerCell.swift
//  LLPhotosPicker
//
//  Created by LOLITA on 2019/4/14.
//  Copyright © 2019 LOLITA0164. All rights reserved.
//

import UIKit

class LLPhotosPickerCell: UITableViewCell {
    // 相簿名称
    var titleLabel: UILabel!
    // 图片数量
    var countLabel: UILabel!
    // 显示图片
    var iconImageView: UIImageView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // 标题
        self.titleLabel = UILabel()
        self.titleLabel.textColor = UIColor.darkText
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        self.addSubview(self.titleLabel)
        //
        self.countLabel = UILabel()
        self.countLabel.textColor = UIColor.gray
        self.countLabel.font = UIFont.systemFont(ofSize: 15)
        self.addSubview(self.countLabel)
        // 显示图片
        self.iconImageView = UIImageView()
        self.iconImageView.backgroundColor = UIColor.groupTableViewBackground
        self.iconImageView.contentMode = .scaleAspectFill
        self.addSubview(self.iconImageView)
        
        // 进行约束设置
        self.iconImageView?.snp.makeConstraints({ (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(self.iconImageView.snp.height)
        })
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.iconImageView.snp.right).offset(10)
            make.right.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(15)
            make.bottom.equalTo(self.countLabel.snp.top).offset(-5)
            make.height.equalTo(20)
        }
        self.countLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.iconImageView.snp.right).offset(10)
            make.right.equalToSuperview().offset(10)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(5)
            make.height.equalTo(15)
        }
        
        // 图片会缩放以最合适的方式填充，我们将多余的部分切除掉
        self.clipsToBounds = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutMargins = UIEdgeInsets.zero
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
