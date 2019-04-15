//
//  LLImageManager.swift
//  LLImagePicker
//
//  Created by LOLITA on 2019/4/14.
//  Copyright © 2019 LOLITA0164. All rights reserved.
//

import UIKit
import Foundation
import Photos

class LLImageManager: NSObject {
    /// 单例
    static let shared:LLImageManager = {
        let instance = LLImageManager()
        return instance
    }()
    /// 将初始化方法私有
    private override init() {}
    
    
    /// GIF 的资源集合
    var gifAssets:[PHAsset]?
    /// GIF 的 ID
    var gifIDs:[String]? {
        didSet {
            let collection = PHAsset.fetchAssets(withLocalIdentifiers: gifIDs!, options: PHFetchOptions())
            self.gifAssets?.removeAll()
            if self.gifAssets == nil { self.gifAssets = [] }
            for i in 0..<collection.count {
                self.gifAssets?.append(collection[i])
            }
        }
    }
}

extension LLImageManager {
    /// 寻找到所有的 GIF 资源
    func requestGIFIDs(completed:@escaping (_ flag:Bool, _ assets:[PHAsset]?)->Void) {
        // 用来存储 GIF 资源
        var assets_new:[PHAsset]?
        
        // iOS11 以上系统
        if #available(iOS 11.0, *) {
            // 寻找系统智能相簿
            let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumAnimated, options: PHFetchOptions())
            // 遍历相簿集
            for i in 0..<smartAlbums.count {
                let c = smartAlbums[i]
                // 找到动图相簿，转换结果回调
                if let title = c.localizedTitle, title == "Animated" {
                    let assetsFetchResult = PHAsset.fetchAssets(in: c, options: PHFetchOptions())
                    for i in 0..<assetsFetchResult.count {
                        let asset = assetsFetchResult[i]
                        // 初始化结果集
                        if assets_new == nil { assets_new = [PHAsset]() }
                        assets_new?.append(asset)
                    }
                    break
                }
            }
            // 回调结果
            completed(true, assets_new)
        }
            
        // iOS11 以下系统
        else {
            // 开起异步线程
            DispatchQueue.global().async {
                // 寻找系统的智能相簿
                let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: PHFetchOptions())
                var ass:PHFetchResult<PHAsset>?
                // 遍历相簿集
                for i in 0..<smartAlbums.count {
                    let c = smartAlbums[i]
                    // 寻找到相机胶卷（全部资源）
                    if let title = c.localizedTitle, title == "Camera Roll" {
                        ass = PHAsset.fetchAssets(in: c, options: PHFetchOptions())
                        break
                    }
                }
                guard let assets = ass else {
                    DispatchQueue.main.async {
                        completed(false, nil)
                    }
                    return
                }
                // 开起队列，寻找 GIF 资源
                let queue = OperationQueue()
                queue.maxConcurrentOperationCount = 10
                assets.enumerateObjects { (asset, _, _) in
                    queue.addOperation({
                        // 同步线程去判断是否是 GIF 类型资源
                        asset.isGIF(isSynchronous: true, completed: { (flag) in
                            if flag {
                                if assets_new == nil { assets_new = [PHAsset]() }
                                assets_new?.append(asset)
                            }
                        })
                    })
                }
                // 阻塞当前所有线程
                queue.waitUntilAllOperationsAreFinished()
                // 回到主线程回调结果
                DispatchQueue.main.async {
                    completed(true, assets_new)
                }
            }
        }
    }
    
    
    
}






import MobileCoreServices
extension PHAsset {
    /// 是否为 GIF 类型的图片
    var isGIF:Bool {
        let resource = PHAssetResource.assetResources(for: self).first!
        // 通过文件后缀来判断
        var suffix = resource.originalFilename
        suffix = suffix.uppercased()
        return suffix.hasSuffix("GIF")
        // 通过 UTI 来判断（可能被修改，发生判断错误）
//        let uti = resource.uniformTypeIdentifier as CFString
//        return UTTypeConformsTo(uti, kUTTypeGIF)
        
    }
    /// 是否为 GIF 类型的图片
    ///
    /// - Parameters:
    ///   - isSynchronous: 是否为同步，默认是异步
    ///   - completed: 回调结果
    func isGIF(isSynchronous:Bool=false, completed:@escaping (_ flag:Bool) -> Void) {
        let requestOption = PHImageRequestOptions()
        requestOption.version = .unadjusted     // 未修改的
        requestOption.isSynchronous = isSynchronous
        PHImageManager.default().requestImageData(for: self, options: requestOption) { (data, uti, orientation, info) in
            if let UTI = uti, UTTypeConformsTo(UTI as CFString, kUTTypeGIF) {
                completed(true)
            } else {
                completed(false)
            }
        }
    }
    
    
}
