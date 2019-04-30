//
//  LLGIFPreviewCtrl.swift
//  LLPhotosPicker
//
//  Created by LOLITA0164 on 2019/4/30.
//  Copyright © 2019年 LOLITA0164. All rights reserved.
//

import UIKit
import Photos
import WebKit

class LLGIFPreviewCtrl: UIViewController {
    
    /// 媒体资源
    var asset:PHAsset!
    
    /// 完成回调
    var completeHandler:LLPhotosManager.handler?
    
    private var webView: WKWebView!
    @IBOutlet weak var completedItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()

    }
    
    /// 设置UI
    private func setupUI() {
        self.view.backgroundColor = UIColor.white
        
        // 导航栏
        let barItem = UIBarButtonItem.init(title: "完成", style: .plain, target: self, action: #selector(self.completed(_:)))
        self.navigationItem.rightBarButtonItem = barItem
        
        // GIF 浏览
        self.webView = WKWebView.init(frame: .zero, configuration: WKWebViewConfiguration.init())
        self.view.addSubview(self.webView)
        self.webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.resizeMode = .fast
        PHImageManager.default().requestImageData(for: self.asset, options: options) { (data, text, orientation, info) in
            DispatchQueue.main.async {
                if let data = data {
                    self.webView.load(data, mimeType: "image/gif", characterEncodingName: "utf-8", baseURL: URL.init(fileURLWithPath: ""))
                    if let source = CGImageSourceCreateWithData(data as CFData, nil) {
                        if let imageRef = CGImageSourceCreateImageAtIndex(source, 0, nil) {
                            let image = UIImage.init(cgImage: imageRef, scale: 1, orientation: UIImage.Orientation.up)
                            self.webView.snp.remakeConstraints({ (make) in
                                make.centerX.equalToSuperview()
                                make.centerY.equalToSuperview().offset(-22)
                                make.width.equalTo(image.size.width)
                                make.height.equalTo(image.size.height)
                            })
                        }
                    }
                }
            }
        }
    }
    
    /// 完成选择
    @IBAction func completed(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: {
            self.completeHandler?([self.asset])
        })
    }
    
}


