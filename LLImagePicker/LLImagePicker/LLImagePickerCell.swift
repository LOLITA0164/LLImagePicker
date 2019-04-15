//
//  LLImagePickerCell.swift
//  LLImagePicker
//
//  Created by LOLITA on 2019/4/14.
//  Copyright © 2019 LOLITA0164. All rights reserved.
//

import UIKit

class LLImagePickerCell: UITableViewCell {
    // 相簿名称
    @IBOutlet weak var titleLabel: UILabel!
    // 图片数量
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutMargins = UIEdgeInsets.zero
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
