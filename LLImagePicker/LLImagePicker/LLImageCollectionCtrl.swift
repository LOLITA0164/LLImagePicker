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
    private var assetsFiltered:[PHAsset] = []
    
    // 带缓存的图片管理对象
    var imageManager:PHCachingImageManager = PHCachingImageManager.init()
    
    // 缩略图大小
    var assetGridThumbnailSize:CGSize!
    
    // 每次最多可选择的照片数量
    var maxCount:Int = Int.max
    
    /// 资源类型
    ///
    /// - image: 图片
    /// - GIF: GIF 动图
    /// - video: 视频
    enum filterType {
        case image, GIF, video
    }
    // 当前要过滤的类型
    private var filterType:filterType = .image
    
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
        self.filterPHAssets(filterType: self.filterType, assets: self.assetsFetchResults)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 主动去获取 GIF 资源
        LLImageManager.shared.fetchGIFAssets(completed: nil)
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
        let dropBox = LLDropBoxView.init(title: "视频", icon: UIImage.init(named: "dorp_box"))
        self.navigationItem.titleView = dropBox
        let op1 = LLOption.init(title: "视频", icon: nil) {
            
        }
        let op2 = LLOption.init(title: "照片", icon: nil) {
            
        }
        let op3 = LLOption.init(title: "GIF", icon: nil) {
            
        }
        dropBox.showOnView(baseView: self.view, options: [op1, op2, op3])
    }
    
    /// 过滤掉不满足要求的资源
    private func filterPHAssets(filterType:filterType, assets:PHFetchResult<PHAsset>?){
        guard let assets = assets else { return }
        var assets_new:[PHAsset] = []
        // 视频部分
        if self.filterType == .video{
            // 遍历所有资源，将 video 的图片类型取出
            assets.enumerateObjects({ (obj, index, stop) in
                if obj.mediaType == .video {
                    assets_new.append(obj)
                }
            })
            self.assetsFiltered = assets_new
            self.collectionView.reloadData()
        }
        // 静态图片
        else if self.filterType == .image {
            LLImageManager.shared.fetchGIFAssets() { [weak self] (flag, gifAssets) in
                guard let gifAssets = gifAssets else { return }
                // 遍历所有资源，将非 GIF 的图片类型取出
                assets.enumerateObjects({ (obj, index, stop) in
                    if gifAssets.contains(obj) == false && obj.mediaType == .image {
                        assets_new.append(obj)
                    }
                })
                self?.assetsFiltered = assets_new
                self?.collectionView.reloadData()
            }
        }
        // GIF
        else {
            LLImageManager.shared.fetchGIFAssets() { [weak self] (flag, gifAssets) in
                guard let gifAssets = gifAssets else { return }
                // 遍历所有资源，将 GIF 的图片类型取出
                assets.enumerateObjects({ (obj, index, stop) in
                    if gifAssets.contains(obj) && obj.mediaType == .image {
                        assets_new.append(obj)
                    }
                })
                self?.assetsFiltered = assets_new
                self?.collectionView.reloadData()
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
        return cell
    }
    // 单元格选中事件
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? LLImageCollectionCell {
            // 获取选中的数量
            let count = self.selectedCount()
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
