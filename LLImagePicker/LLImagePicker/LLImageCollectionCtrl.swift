//
//  LLImageCollectionCtrl.swift
//  LLImagePicker
//
//  Created by LOLITA on 2019/4/14.
//  Copyright © 2019 LOLITA0164. All rights reserved.
//

import UIKit
import Photos

// MARK:- 图片缩略图集合控制器
class LLImageCollectionCtrl: UIViewController {
    // 显示多有图片缩略图的 collectionView
    @IBOutlet weak var collectionView: UICollectionView!
    // 底部的工具栏
    @IBOutlet weak var toolBar: UIToolbar!
    
    // 外部传递进来的资源结果，存放了 PHAsset
    var assetsFetchResults:PHFetchResult<PHAsset>?
    
    // 经过滤后的资源集合
    private var assetsFiltered:[PHAsset] = [] {
        didSet {
            // 当数据为空时，需要添加提示视图
            if self.assetsFiltered.count == 0 {
                let title = "无" + LLImageManager.shared.filterType.rawValue
                let des = String.init(format: "%@相册里不存在存储的%@。", self.title ?? "", LLImageManager.shared.filterType.rawValue)
                self.collectionView.addTipView(title: title, des: des, actionTitle: nil, target: nil, action: nil)
                self.toolBar.isHidden = true
            } else {
                self.collectionView.removeTipView()
                self.toolBar.isHidden = false
            }
        }
    }
    
    // 带缓存的图片管理对象
    var imageManager:PHCachingImageManager = PHCachingImageManager.init()
    
    // 缩略图大小
    var assetGridThumbnailSize:CGSize!
    
    // 每次最多可选择的照片数量
    var maxCount:Int = Int.max
    
    // 照片选择完后的回调
    var completeHandler:LLImagePickerCtrl.handler?
    
    //完成按钮
    var completeButton:LLImageCompleteButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 根据单元格的尺寸获取到我们正真需要的缩略图大小
        let scale = UIScreen.main.scale
        let cellSize = (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        self.assetGridThumbnailSize = CGSize.init(width: cellSize.width * scale,
                                                  height: cellSize.height * scale)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        // 过滤掉不满足条件的资源
        self.filterPHAssets(assets: self.assetsFetchResults)
    }
    
    // 设置UI
    private func setupUI() {
        // 重制缓存
        self.imageManager.stopCachingImagesForAllAssets()
        
        // 设置单元格尺寸
        let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize.init(width: UIScreen.main.bounds.size.width/4-1,
                                      height: UIScreen.main.bounds.size.width/4-1)
        // 允许多选
        self.collectionView.allowsMultipleSelection = true
        
        // 默认隐藏工具栏
        self.toolBar.isHidden = true
        
        // 设置导航右侧的取消按钮
        let rightBarItem = UIBarButtonItem.init(title: "取消", style: .plain, target: self, action: #selector(self.cancel))
        self.navigationItem.rightBarButtonItem = rightBarItem
        
        // 添加下方工具栏的完成按钮
        self.completeButton = LLImageCompleteButton()
        self.completeButton.addTarget(target: self, action: #selector(self.finishSelect))
        self.completeButton.isEnabled = false
        let rigtBarItem = UIBarButtonItem.init(customView: self.completeButton)
        let flexible = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        self.toolBar.items = [flexible,rigtBarItem]
        
        // 设置导航部分
        let dropBox = LLDropBoxView.init(title: LLImageManager.shared.filterType.rawValue, icon: UIImage.init(named: "dorp_box"))
        self.navigationItem.titleView = dropBox
        let op1 = LLOption.init(title: "视频", icon: UIImage.init(named: "video")!) { [weak self] in
            guard LLImageManager.shared.filterType != .video else { return }
            LLImageManager.shared.filterType = .video
            self?.filterPHAssets(assets: self?.assetsFetchResults)
        }
        let op2 = LLOption.init(title: "照片", icon: UIImage.init(named: "image")!) { [weak self] in
            guard LLImageManager.shared.filterType != .image else { return }
            LLImageManager.shared.filterType = .image
            self?.filterPHAssets(assets: self?.assetsFetchResults)
        }
        let op3 = LLOption.init(title: "GIF", icon: UIImage.init(named: "gif")!) { [weak self] in
            guard LLImageManager.shared.filterType != .GIF else { return }
            LLImageManager.shared.filterType = .GIF
            self?.filterPHAssets(assets: self?.assetsFetchResults)
        }
        dropBox.showOnView(baseView: self.view, options: [op1, op2, op3])
    }
    
    /// 过滤掉不满足要求的资源
    private func filterPHAssets(assets:PHFetchResult<PHAsset>?){
        guard let assets = assets else { return }
        // 开启指示器
        self.view.HUD?.center = CGPoint.init(x: UIScreen.main.bounds.width/2.0, y: UIScreen.main.bounds.height/2.0 - self.toolBar.bounds.height)
        self.view.HUD?.start()
        // 由于过滤资源可能需要花费很长时间，所有开启异步线程去筛选数据
        DispatchQueue.global().async {
            var assets_new:[PHAsset] = []
            // 视频部分
            if LLImageManager.shared.filterType == .video {
                // 遍历所有资源，将 video 的图片类型取出
                assets.enumerateObjects({ (obj, index, stop) in
                    if obj.mediaType == .video {
                        assets_new.append(obj)
                    }
                })
                DispatchQueue.main.async {
                    self.view.HUD?.hide()
                    // 重新设置过滤后的数据
                    self.assetsFiltered = assets_new
                    self.collectionView.reloadData()
                    // 视频类型中，隐藏完成选项
                    
                }
            }
                // 静态图片
            else if LLImageManager.shared.filterType == .image {
                LLImageManager.shared.fetchGIFAssets() { [weak self] (flag, gifAssets) in
                    // 遍历所有资源，将非 GIF 的图片类型取出
                    if let gifAssets = gifAssets {
                        assets.enumerateObjects({ (obj, index, stop) in
                            if gifAssets.contains(obj) == false && obj.mediaType == .image {
                                assets_new.append(obj)
                            }
                        })
                    } else {
                        assets.enumerateObjects({ (obj, index, stop) in
                            if obj.mediaType == .image {
                                assets_new.append(obj)
                            }
                        })
                    }
                    DispatchQueue.main.async {
                        self?.view.HUD?.hide()
                        // 重新设置过滤后的数据
                        self?.assetsFiltered = assets_new
                        self?.collectionView.reloadData()
                        // 图片类型中，隐藏完成选项
                        
                    }
                }
            }
                // GIF
            else {
                LLImageManager.shared.fetchGIFAssets() { [weak self] (flag, gifAssets) in
                    // 遍历所有资源，将 GIF 的图片类型取出
                    if let gifAssets = gifAssets {
                        assets.enumerateObjects({ (obj, index, stop) in
                            if gifAssets.contains(obj) && obj.mediaType == .image {
                                assets_new.append(obj)
                            }
                        })
                    }
                    DispatchQueue.main.async {
                        self?.view.HUD?.hide()
                        // 重新设置过滤后的数据
                        self?.assetsFiltered = assets_new
                        self?.collectionView.reloadData()
                        // GIF类型中，隐藏完成选项
                        
                    }
                }
            }
        }
    }
    
    // 取消按钮事件
    @objc func cancel(){
        self.dismiss(animated: true, completion: nil)
    }
    
    // 完成按钮事件
    @objc func finishSelect() {
        // 取出已选择的图片资源
        var assets:[PHAsset] = []
        if let indexPaths = self.collectionView.indexPathsForSelectedItems {
            for indexPath in indexPaths {
                assets.append(self.assetsFiltered[indexPath.row])
            }
        }
        // 回调结果
        self.dismiss(animated: true) {
            self.completeHandler?(assets)
        }
    }

    
    // 获取已经选择的个数
    private func selectedCount() -> Int {
        return self.collectionView.indexPathsForSelectedItems?.count ?? 0
    }

}


// MARK:- 实现图片缩略图控制器的 UICollectionViewDataSource、UICollectionViewDelegate 协议
extension LLImageCollectionCtrl: UICollectionViewDelegate,UICollectionViewDataSource {
    // 个数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assetsFiltered.count
    }
    // 单元格样式
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 获取 stroyboard 的集合单元格，不需要再动态添加
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! LLImageCollectionCell
        // 获取到资源
        let asset = self.assetsFiltered[indexPath.row]
        // 获取到缩略图
        self.imageManager.requestImage(for: asset, targetSize: self.assetGridThumbnailSize, contentMode: .aspectFill, options: nil) { (image, info) in
            cell.imageView.image = image
        }
        switch LLImageManager.shared.filterType {
        case .video:
            cell.selectedIconImageView.isHidden = true
            cell.subLabel.isHidden = false
            cell.subLabel.text = String.from(timeInterval: asset.duration)
            break
        case .GIF:
            cell.selectedIconImageView.isHidden = true
            cell.subLabel.isHidden = false
            cell.subLabel.text = "GIF"
            break
        case .image:
            cell.selectedIconImageView.isHidden = false
            cell.subLabel.isHidden = true
            break
        }
        return cell
    }
    // 单元格选中事件
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? LLImageCollectionCell {
            // 获取选中的数量
            let count = self.selectedCount()
            // 如果是当前类型是视频或者GIF时，则直接回调数据
            if LLImageManager.shared.filterType != .image {
                self.finishSelect()
            }
            // 当所选择的数量超过上限时，进行提示
            if count > self.maxCount {
                // 将当前的 cell 设置为不选中状体
                collectionView.deselectItem(at: indexPath, animated: false)
                // 弹出提醒
                let title = "最多只能选择" + String(self.maxCount) + "张照片"
                let alertCtrl = UIAlertController.init(title: title, message: nil, preferredStyle: UIAlertController.Style.alert)
                let cancelAction = UIAlertAction.init(title: "我知道了", style: .cancel, handler: nil)
                alertCtrl.addAction(cancelAction)
                self.present(alertCtrl, animated: true, completion: nil)
            }
            else {
                // 改变完成按钮的数字，并播放动画
                self.completeButton.num = count
                if count > 0 && !self.completeButton.isEnabled{
                    self.completeButton.isEnabled = true
                }
                cell.playAnimate()
            }
        }
    }
    // 单元格取消选中事件
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? LLImageCollectionCell {
            let count = self.selectedCount()
            // 改变完成按钮数字，并播放动画
            self.completeButton.num = count
            if count == 0{
                self.completeButton.isEnabled = false
            }
            cell.playAnimate()
        }
    }
    
}




// MARK:- 字符串转换
extension String {
    /// 将时间数字转换为字符串
    static func from(timeInterval interval:TimeInterval) -> String {
        let ti = NSInteger(interval)
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
//        let hours = (ti / 3600)
        return String(format: "%0.2d:%0.2d",minutes,seconds)
    }
}
