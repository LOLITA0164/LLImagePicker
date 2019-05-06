//
//  ViewController.swift
//  LLImagePicker
//
//  Created by LOLITA on 2019/4/14.
//  Copyright © 2019 LOLITA0164. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func clickAction(_ sender: UIButton) {
        // 过滤资源类型
//        LLPhotosManager.shared.filterStyle = [.image]
        // 当前显示的资源类型
        LLPhotosManager.shared.currentMediaType = .video
        // 显示资源
        _ = self.presentLLPhotosPicker(maxCount: 9, completeHandler: { (assets) in
            print(assets)
        })
    }
    

}

