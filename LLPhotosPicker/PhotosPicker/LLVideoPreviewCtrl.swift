//
//  LLVideoPreviewCtrl.swift
//  LLPhotosPicker
//
//  Created by LOLITA0164 on 2019/4/30.
//  Copyright © 2019年 LOLITA0164. All rights reserved.
//

import UIKit
import Photos
import AVKit

class LLVideoPreviewCtrl: UIViewController {

    /// 媒体资源
    var asset:PHAsset!
    
    /// 完成回调
    var completeHandler:LLPhotosManager.handler?
    
    /// 播放器
    private var player:AVPlayer!
    /// 视频资源
    private var currentPlayerItem:AVPlayerItem!
    /// 播放图层
    private var avLayer:AVPlayerLayer!
    /// 显示播放视图
    let playView: UIView = UIView()
    /// 播放按钮
    let playBtnBGView: UIView = UIView()
    let playBtn = UIButton.init(frame: CGRect.init(origin: .zero, size: CGSize.init(width: 55, height: 55)))
    /// 进度控制视图
//    @IBOutlet var progressCtrlView: UIView!
//    @IBOutlet weak var progressSlider: UISlider!    // 进度滑杆
//    @IBOutlet weak var beginLabel: UILabel!         // 开始的标签
//    @IBOutlet weak var endLabel: UILabel!           // 结束的标签
    let progressCtrlView = LLVideoPreviewCtrlView.init(frame: CGRect.init(origin: .zero, size: CGSize.init(width: 300, height: 44)))
    /// 是否正在seeking
    private var seeking:Bool = false
    /// 播放时间对象，需要手动释放
    var timeObserverToken:Any?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.isTranslucent = false
        // 在可能的侧滑情况下暂停播放
        if self.player != nil {
            self.playBtn.isSelected = true
            self.playAction(self.playBtn)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.fetchAsset()
    }
    
    /// 设置UI
    private func setupUI() {
        self.view.backgroundColor = UIColor.black
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(named: "white"), for: .default)
        
        // 设置导航栏
        let barItem = UIBarButtonItem.init(title: "完成", style: .plain, target: self, action: #selector(self.completed(_:)))
        self.navigationItem.rightBarButtonItem = barItem
        
        // 视频播放视图
        self.view.addSubview(self.playView)
        self.playView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        // 播放按钮及其背景视图
        self.view.addSubview(self.playBtnBGView)
        self.playBtnBGView.addSubview(self.playBtn)
        self.playBtnBGView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.playBtn.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(55)
        }
        self.playBtn.layer.masksToBounds = true
        self.playBtn.layer.cornerRadius = self.playBtn.layer.bounds.height / 2.0
        self.playBtn.addTarget(self, action: #selector(self.playAction(_:)), for: .touchUpInside)
        
        // 设置底部工具栏
        self.navigationController?.toolbar.tintColor = LLPhotosManager.shared.themeColor
        let flexibleSpace = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let progressView = UIBarButtonItem.init(customView: self.progressCtrlView)
        self.setToolbarItems([flexibleSpace, progressView, flexibleSpace], animated: false)
        
        // 设置播放按钮
        self.playBtn.layer.cornerRadius = self.playBtn.bounds.height / 2.0
        self.playBtn.layer.masksToBounds = true
        self.playBtn.setImage(UIImage.init(named: "play"), for: .normal)
        self.playBtn.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        self.playBtn.alpha = 0
        
        // 设置进度
        self.progressCtrlView.progressSlider.setThumbImage(UIImage.init(named: "spot")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.progressCtrlView.progressSlider.tintColor = LLPhotosManager.shared.themeColor
        self.progressCtrlView.progressSlider.addTarget(self, action: #selector(self.progressValueChangedAction(_:)), for: .valueChanged)
        self.progressCtrlView.progressSlider.addTarget(self, action: #selector(self.progressTouchUpInsideAction(_:)), for: .touchUpInside)
    }
    
    
    /// 获取资源
    private func fetchAsset() {
        // 获取视频资源
        PHImageManager.default().requestPlayerItem(forVideo: self.asset, options: nil) { (avplayerItem, info) in
            DispatchQueue.main.async {
                if let playerItem = avplayerItem {
                    // 创建视频资源
                    self.currentPlayerItem = playerItem
                    // 初始化播放器
                    self.player = AVPlayer.init(playerItem: playerItem)
                    // 初始化播放视图
                    self.avLayer = AVPlayerLayer.init(player: self.player)
                    self.avLayer.videoGravity = .resizeAspect
                    self.avLayer.frame = self.view.bounds
                    self.playView.layer.addSublayer(self.avLayer)
                    // 添加视频资源监听事件
                    self.addObserverPlayerItem()
                    // 添加播放时间回调
                    self.timeObserverToken = self.player.addPeriodicTimeObserver( forInterval: CMTime.init(value: 1, timescale: 1), queue: nil, using: { [weak self] (time) in
                        guard self?.seeking == false else { return }
                        // 回到主线程中更新UI
                        self?.progressCtrlView.beginLabel.text = String.from(timeInterval: TimeInterval(time.seconds))
                        self?.progressCtrlView.progressSlider.value = Float(time.seconds)
                    })
                    
                }
            }
        }
    }
    
    
    /// 给资源添加观察器
    private func addObserverPlayerItem() {
        // 播放资源状态
        self.player.currentItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        // 添加播放通知
        NotificationCenter.default.addObserver(self, selector: #selector(self.playEndAction), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.playPauseAction), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.playPauseAction), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let playerItem = object as? AVPlayerItem , let change = change {
            if keyPath == "status" {
                if let status = change[NSKeyValueChangeKey.newKey] as? Int {
                    if status == AVPlayerItem.Status.readyToPlay.rawValue {
                        self.playBtn.alpha = 1
                        self.playBtn.isSelected = false
                        self.playAction(self.playBtn)
                        // 设置总时长
                        self.progressCtrlView.endLabel.text = String.from(timeInterval: TimeInterval(playerItem.duration.seconds))
                        self.progressCtrlView.progressSlider.maximumValue = Float(playerItem.duration.seconds)
                    } else if status == AVPlayerItem.Status.failed.rawValue {
                        print("视频加载失败")
                        self.playBtn.alpha = 1
                        self.playBtn.isSelected = true
                        self.playAction(self.playBtn)
                    } else {
                        print("视频加载发生未知错误")
                        self.playBtn.alpha = 1
                        self.playBtn.isSelected = true
                        self.playAction(self.playBtn)
                    }
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    /// 完成选择
    @objc private func completed(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: {
            self.completeHandler?([self.asset])
        })
    }

    /// 视频播放事件
    @objc private func playAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected{
            self.playBtn.imageEdgeInsets = UIEdgeInsets.zero
            self.playBtn.setImage(UIImage.init(named: "pause"), for: .normal)
            self.player.play()
            // 播放时隐藏当前播放按钮，隐藏导航、工具栏
            sender.alpha = 0
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.navigationController?.setToolbarHidden(true, animated: true)
        }else{
            self.playBtn.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 5, bottom: 0, right: 0)
            self.playBtn.setImage(UIImage.init(named: "play"), for: .normal)
            self.player.pause()
            // 未播放时显示当前播放按钮，隐藏导航、工具栏
            sender.alpha = 1
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationController?.setToolbarHidden(false, animated: true)
        }
    }
    
    /// 在一些情况下暂停播放
    @objc private func playPauseAction() {
        self.playBtn.isSelected = true
        self.playAction(self.playBtn)
    }
    /// 在播发结束后暂停播放，将进度seek到最初
    @objc private func playEndAction() {
        self.playBtn.isSelected = true
        self.playAction(self.playBtn)
        self.player.seek(to: .zero)
    }
    
    /// 进度条滑动事件
    @objc private func progressValueChangedAction(_ sender: UISlider) {
        // 当前的状态更换为 seeking
        self.seeking = true
        // 当前播放
        self.playPauseAction()
        // 跳转进度时间
        let newTime = CMTimeMake(value: Int64(sender.value), timescale: 1)
        self.player.seek(to: newTime)
    }
    /// 进度
    @objc private func progressTouchUpInsideAction(_ sender: UISlider) {
        // 重新播放
        self.seeking = false
        self.playBtn.isSelected = true
        self.playBtn.imageEdgeInsets = UIEdgeInsets.zero
        self.playBtn.setImage(UIImage.init(named: "pause"), for: .normal)
        self.player.play()
        self.playBtn.alpha = 0
    }
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.navigationController?.isNavigationBarHidden == true {
            // 当点击屏幕时，需要将播放按钮显示出来，同时展示导航，工具栏
            self.playBtn.alpha = 1
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationController?.setToolbarHidden(false, animated: true)
        } else {
            self.playBtn.alpha = 0
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
    }
    
    
    deinit {
        // 移除时间回调对象
        if self.timeObserverToken != nil {
            self.player.removeTimeObserver(self.timeObserverToken!)
        }
        // 移除一些KVO
        self.player.pause()
        self.player.currentItem?.cancelPendingSeeks()
        self.player.currentItem?.removeObserver(self, forKeyPath: "status")
        self.currentPlayerItem = nil
        self.player = nil
        self.avLayer = nil
        // 注销通知部分
        NotificationCenter.default.removeObserver(self)
    }
    
}




extension LLVideoPreviewCtrl:UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer && self.navigationController?.viewControllers.count ?? 0 < 2 {
            return false
        }
        return true
    }
}





// MARK:- 视频进度控制视图
class LLVideoPreviewCtrlView: UIView {
    
    /// 开始的标签
    lazy var beginLabel: UILabel = {
        let tmp = UILabel()
        tmp.textColor = UIColor.darkText
        tmp.textAlignment = .right
        tmp.font = UIFont.systemFont(ofSize: 14)
        return tmp
    }()
    
    /// 结束的标签
    lazy var endLabel: UILabel = {
        let tmp = UILabel()
        tmp.textColor = UIColor.darkText
        tmp.textAlignment = .left
        tmp.font = UIFont.systemFont(ofSize: 14)
        return tmp
    }()
    
    /// 进度控制
    lazy var progressSlider: UISlider = {
        let tmp = UISlider.init()
        return tmp
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    /// 初始化UI
    private func setupUI() {
        self.addSubview(self.beginLabel)
        self.addSubview(self.progressSlider)
        self.addSubview(self.endLabel)
        self.beginLabel.snp.makeConstraints { (make) in
            make.width.equalTo(40)
            make.left.top.bottom.equalToSuperview()
        }
        self.endLabel.snp.makeConstraints { (make) in
            make.width.equalTo(40)
            make.right.top.bottom.equalToSuperview()
        }
        self.progressSlider.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(self.beginLabel.snp.right).offset(5)
            make.right.equalTo(self.endLabel.snp.left).offset(-5)
        }
    }
    
}
