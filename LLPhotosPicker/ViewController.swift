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
//        LLPhotosManager.shared.filterStyle = [.video]
        let _ = self.presentLLPhotosPicker { (assets) in
            print(assets)
        }
        
    }
    

}

