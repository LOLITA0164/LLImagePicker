//
//  LLPhotosPreviewCtrl.swift
//  LLPhotosPicker
//
//  Created by LOLITA on 2019/5/4.
//  Copyright © 2019 LOLITA0164. All rights reserved.
//

import UIKit
import Photos

// MARK:- 浏览图片
class LLPhotosPreviewCtrl: UIViewController {
    
    /// 存放图片资源
    var assets:[PHAsset]!
    /// 集合视图
    lazy var collectionView: UICollectionView = {
        // 设置单元格尺寸
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize.init(width: UIScreen.main.bounds.width,
                                      height: UIScreen.main.bounds.height)
        layout.scrollDirection = .horizontal
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let tmp = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        tmp.delegate = self
        tmp.dataSource = self
        tmp.isPagingEnabled = true
        tmp.showsHorizontalScrollIndicator = false
        tmp.showsVerticalScrollIndicator = false
        return tmp
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }

    func setupUI() {
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = LLPhotosManager.shared.themeColor
        
        if #available(iOS 11.0, *) {
            self.collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        // 设置导航
        let cancelBarItem = UIBarButtonItem.init(title: "取消", style: .plain, target: self, action: #selector(self.cancel))
        self.navigationItem.leftBarButtonItem = cancelBarItem
        self.title = String.init(format: "%ld / %ld", 1,self.assets.count)
        
        // 初始化网格视图
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.register(LLPhotosPreviewCell.classForCoder(), forCellWithReuseIdentifier: "cell")
        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    @objc private func cancel() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

}


// MARK:- 集合视图的协议方法
extension LLPhotosPreviewCtrl:UICollectionViewDelegate, UICollectionViewDataSource {
    // 集合样式数量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assets.count
    }
    // cell 样式
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! LLPhotosPreviewCell
        if let asset = self.assets?[indexPath.row] {
            PHCachingImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.default, options: nil) { (image, info) in
                cell.imageView.image = image
            }
        }
        cell.scrollView.zoomScale = 1
        return cell
    }
    // 滚动分页
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        self.title = String.init(format: "%ld / %ld", page+1,self.assets.count)
    }
}






// MARK:- 集合cell的样式
class LLPhotosPreviewCell: UICollectionViewCell,UIScrollViewDelegate {
    // 用于放大视图
    lazy var scrollView: UIScrollView = {
        let tmp = UIScrollView.init(frame: self.bounds)
        tmp.delegate = self
        tmp.showsVerticalScrollIndicator = false
        tmp.showsHorizontalScrollIndicator = false
        tmp.minimumZoomScale = 0.5
        tmp.maximumZoomScale = 3
        return tmp
    }()
    // 展示图片
    lazy var imageView: UIImageView = {
        let tmp = UIImageView.init(frame: self.bounds)
        tmp.contentMode = .scaleAspectFit
        tmp.isUserInteractionEnabled = true
        return tmp
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.scrollView)
        self.scrollView.addSubview(self.imageView)
    }
    
    /// 缩放的视图
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    /// 放大代理
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = scrollView.bounds.width > scrollView.contentSize.width ? (scrollView.bounds.width - scrollView.contentSize.width) / 2.0 : 0
        let offsetY = scrollView.bounds.height > scrollView.contentSize.height ? (scrollView.bounds.height - scrollView.contentSize.height) / 2.0 : 0
        self.imageView.center = CGPoint.init(x: scrollView.contentSize.width/2.0+offsetX, y: scrollView.contentSize.height/2.0+offsetY)
    }
}
