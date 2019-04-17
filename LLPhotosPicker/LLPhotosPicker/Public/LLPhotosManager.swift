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

// MARK:- 图片资源管理类
class LLPhotosManager: NSObject {
    /// 单例
    static let shared:LLPhotosManager = {
        let instance = LLPhotosManager()
        return instance
    }()
    /// 将初始化方法私有
    private override init() {}
    
    /// 记录用户当前选择的资源类型
    var filterType:filterType = .video
    
    /// 当前的主题色
    var themeColor = UIColor.init(red: 91/255.0, green: 181/255.0, blue: 63/255.0, alpha: 1)
    
    
    /// 已经选择的资源，后期需要更上
    var selectedAssets:[PHAsset]?
    
    
}

// MARK:- 定义资源类型
extension LLPhotosManager {
    /// 资源类型
    enum filterType:String {
        case image = "图片"
        case GIF = "GIF"
        case video = "视频"
    }
}



// MARK:- 获取相册中所有 GIF 的资源集合
extension LLPhotosManager {
    
    /// 用于iOS11以下系统存储 GIF 资源的 localIdentifier
    private var gifIDs:[String]? {
        get {
            let array = UserDefaults.standard.array(forKey: "gifIDs") as? [String]
            return array
        }
        set {
            if newValue == nil {
                UserDefaults.standard.set([String](), forKey: "gifIDs")
            } else {
                UserDefaults.standard.set(newValue, forKey: "gifIDs")
            }
        }
    }
    
    /// 寻找到所有的 GIF 资源
    func fetchGIFAssets(completed:((_ flag:Bool, _ assets:[PHAsset]?)->Void)?) {
        // 用来存储 GIF 资源
        var assets_new:[PHAsset]?
        
        // iOS11 以上系统，直接获取动图比较快，因此不错缓存 gifIDs 操作
        if #available(iOS 11.0, *) {
            DispatchQueue.global().async {
                // 寻找系统智能相簿中的 动图 相簿
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
                DispatchQueue.main.async {
                    // 回调结果
                    completed?(true, assets_new)
                }
            }
        }
            
        // iOS11 以下系统
        else {
            // 如果本地存在 gifIDs，则优先使用获取
            if self.gifIDs != nil {
                let collection = PHAsset.fetchAssets(withLocalIdentifiers: self.gifIDs!, options: PHFetchOptions())
                var list = [PHAsset]()
                for i in 0..<collection.count {
                    list.append(collection[i])
                }
                // 系统会默认将新的资源先取到，这和我们再次进行排序
                list.sort { (obj1, obj2) -> Bool in
                    return obj1.creationDate?.compare(obj2.creationDate!) == .orderedDescending
                }
                completed?(true, list)
            }
            
            // 用来存储 GIF 资源的 localIdentifier
            var localIdentifiers:[String]?
            
            // 开起异步线程
            DispatchQueue.global().async {
                // 寻找系统的所有资源
                //  注意点！！-这里必须注册通知，不然第一次运行程序时获取不到图片，以后运行会正常显示
//                PHPhotoLibrary.shared().register(self)
                let allOptions = PHFetchOptions()
                // 给资源进行排序 由远到近
                allOptions.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: false)]
                // 获取到所有的资源
                let assets = PHAsset.fetchAssets(with: allOptions)
                // 开起队列，寻找 GIF 资源
                let queue = OperationQueue()
                queue.maxConcurrentOperationCount = 5
                assets.enumerateObjects { (asset, _, _) in
                    queue.addOperation({
                        // 同步线程去判断是否是 GIF 类型资源
                        if asset.isGIF {
                            if assets_new == nil { assets_new = [PHAsset]() }
                            if localIdentifiers == nil { localIdentifiers = [String]() }
                            assets_new?.append(asset)
                            localIdentifiers?.append(asset.localIdentifier)
                        }
                    })
                }
                // 阻塞当前所有线程
                queue.waitUntilAllOperationsAreFinished()
                // 回到主线程回调结果
                DispatchQueue.main.async {
                    // 如果本地中不存在 gifIDs，则表示需要回调刷新数据，否则不回调数据，只作存储
                    if self.gifIDs == nil {
                        completed?(true, assets_new)
                    }
                    // 重新将新的 GIFIDs 缓存到本地
                    self.gifIDs = localIdentifiers
                }
            }
        }
    }
    
    // 代理方法
//    func photoLibraryDidChange(_ changeInstance: PHChange) {
//        self.fetchGIFAssets(completed: nil)
//    }
    
}





// MARK:- PHAsset判断是否是 GIF 类型
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
        requestOption.resizeMode = .exact
        PHImageManager.default().requestImageData(for: self, options: requestOption) { (data, uti, orientation, info) in
            if let UTI = uti, UTTypeConformsTo(UTI as CFString, kUTTypeGIF) {
                completed(true)
            } else {
                completed(false)
            }
        }
    }
    
}



// MARK:- 根据条件获取图片
extension LLPhotosManager {
    /// 生成高斯模糊图片
    static func asGaussianBlurImage(blurRadius:CGFloat=0.5,image:UIImage) -> UIImage? {
        var resultImage:UIImage?
        //获取原始图片
        let inputImage =  CIImage(image: image)
        //使用高斯模糊滤镜
        let filter = CIFilter(name: "CIGaussianBlur")!
        filter.setValue(inputImage, forKey:kCIInputImageKey)
        //设置模糊半径值（越大越模糊）
        filter.setValue(max(min(1.0, blurRadius), 0), forKey: kCIInputRadiusKey)
        let outputCIImage = filter.outputImage!
        let rect = CGRect(origin: CGPoint.zero, size: image.size)
        let cgImage = CIContext(options: nil).createCGImage(outputCIImage, from: rect)
        //显示生成的模糊图片
        resultImage = UIImage.init(cgImage: cgImage!)
        return resultImage
    }
    
    /// 根据颜色获取图片
    static func generateImage(color:UIColor,imageSize:CGSize = CGSize(width: 1.0, height: 1.0)) -> UIImage?{
        let rect = CGRect(x: 0.0, y: 0.0, width: imageSize.width, height: imageSize.height)
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer.init(bounds: rect)
            let image = renderer.image { (context) in
                color.setFill()
                UIBezierPath.init(rect: rect).fill()
            }
            return image
        } else {
            UIGraphicsBeginImageContext(rect.size)
            let context = UIGraphicsGetCurrentContext()!
            context.setFillColor(color.cgColor)
            context.fill(rect)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
    }
}



// MARK:- 获取当前视图的图片
extension UIView {
    /// 获取当前截图
    func asImage(rect:CGRect?=nil) -> UIImage? {
        let bounds = rect == nil ? self.bounds : rect!
        // 该类于 iOS10 之后引入
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer.init(bounds: bounds)
            let image = renderer.image { (context) in
                self.layer.render(in: context.cgContext)
            }
            return image
        } else {
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
            self.layer.render(in: UIGraphicsGetCurrentContext()!)
            let coverImage = UIGraphicsGetImageFromCurrentImageContext()
            if rect == nil {
                UIGraphicsEndImageContext()
                return coverImage
            }else{
                let targetLayer = CALayer()
                targetLayer.bounds = CGRect.init(origin: .zero, size: rect!.size)
                targetLayer.contents = coverImage?.cgImage
                targetLayer.contentsRect = CGRect.init(x: rect!.origin.x / self.layer.bounds.size.width,
                                                       y: rect!.origin.y / self.layer.bounds.size.height,
                                                       width: rect!.size.width / self.layer.bounds.size.width,
                                                       height: rect!.size.height / self.layer.bounds.size.height)
                UIGraphicsBeginImageContextWithOptions(targetLayer.bounds.size, false, 0.0)
                targetLayer.render(in: UIGraphicsGetCurrentContext()!)
                let coverImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return coverImage
            }
        }
    }
}
