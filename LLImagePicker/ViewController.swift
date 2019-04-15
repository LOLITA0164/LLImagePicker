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
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func clickAction(_ sender: UIButton) {
        let _ = self.presentLLImagePicker { (assets) in
            for asset in assets {
                print(asset)
            }
        }
        
    }
    

}

