//
//  LLProgressHUD.swift
//  LLPhotosPicker
//
//  Created by LOLITA0164 on 2019/4/16.
//  Copyright © 2019年 LOLITA0164. All rights reserved.
//

import UIKit

// MARK:- 进度指示器
class LLProgressHUD: UIView {

    // 定时器
    private lazy var link:CADisplayLink = {
        let tmp = CADisplayLink.init(target: self, selector: #selector(self.displayLinkActionEvent))
        tmp.add(to: RunLoop.main, forMode: .default)
        return tmp
    }()
    
    // 动画图层
    private lazy var animationLayer: CAShapeLayer = {
        let tmp = CAShapeLayer()
        tmp.bounds = CGRect.init(origin: .zero, size: self.circleSize)
        tmp.position = CGPoint.init(x: self.bounds.size.width/2.0, y: self.bounds.size.height/2.0)
        tmp.fillColor = UIColor.clear.cgColor
        tmp.strokeColor = self.fillColor.cgColor
        tmp.lineWidth = CGFloat(self.lineWidth)
        tmp.lineCap = .round
        return tmp
    }()
    
    // 图层的一些属性
    private var startAngle = Double(0)
    private var endAngle = Double(0)
    private var progress = Double(0)
    
    /// 线条宽度
    var lineWidth = Double(4.0) {
        didSet {
            self.animationLayer.lineWidth = CGFloat(self.lineWidth)
        }
    }
    // 线条填充色
    var fillColor = LLPhotosManager.shared.themeColor {
        didSet {
            self.animationLayer.strokeColor = self.fillColor.cgColor
        }
    }
    
    // circle尺寸
    var circleSize = CGSize.init(width: 40, height: 40) {
        didSet {
            self.animationLayer.bounds = CGRect.init(origin: .zero, size: self.circleSize)
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    /// 设置 UI
    private func setupUI() {
        // 动画图层
        self.layer.addSublayer(self.animationLayer)
        // 定时器
        self.hide()
    }
    
    /// 定时器部分
    @objc func displayLinkActionEvent() {
        self.progress += self.speed()
        if self.progress >= 1 {
            self.progress = 0
        }
        self.updateAnimationLayer()
    }
    
    /// 更新样式
    private func updateAnimationLayer() {
        self.startAngle = -(Double.pi/2.0)
        self.endAngle = -(Double.pi/2.0) + self.progress*Double.pi*2
        if self.endAngle > Double.pi {
            let progress1 = 1 - ( 1 - self.progress ) / 0.25
            self.startAngle = -(Double.pi)/2.0 + progress1*Double.pi*2
        }
        let radius = self.animationLayer.bounds.width/2.0 - CGFloat(self.lineWidth/2.0)
        let center = CGPoint.init(x: self.animationLayer.bounds.width/2.0,
                                  y: self.animationLayer.bounds.height/2.0)
        let path = UIBezierPath.init(arcCenter: center, radius: radius, startAngle: CGFloat(self.startAngle), endAngle: CGFloat(self.endAngle), clockwise: true)
        path.lineCapStyle = .round
        self.animationLayer.path = path.cgPath
    }
    
    /// 速度
    private func speed() -> Double {
        if self.endAngle > Double.pi {
            return 0.3 / 60.0
        }
        return 2.0 / 60.0
    }
    
}


extension LLProgressHUD {
    /// 是否执行动画
    var isAnimating: Bool {
        get {
            return !self.link.isPaused
        }
    }
    
    /// 配置其他属性
    func setup(color:UIColor?, lineWidth:CGFloat?, circle:CGSize?) {
        if let c = color {
            self.fillColor = c
        }
        if let line = lineWidth {
            self.lineWidth = Double(line)
        }
        if let circle = circle {
            self.circleSize = circle
        }
    }
    
    /// 开启动画
    func start() {
        self.link.isPaused = false
        self.isHidden = false
    }
    /// 隐藏动画
    func hide() {
        self.link.isPaused = true
        self.startAngle = 0
        self.endAngle = 0
        self.progress = 0
        self.updateAnimationLayer()
        self.isHidden = true
    }
    
    /// 显示
    class func show(in view:UIView, animate:Bool=false) -> LLProgressHUD {
        _ = self.hide(in: view)
        let hud = LLProgressHUD.init(frame: view.bounds)
        if animate {
            hud.start()
        }
        view.addSubview(hud)
        return hud
    }
    
    /// 隐藏
    class func hide(in view:UIView) -> LLProgressHUD? {
        var hud:LLProgressHUD?
        for item in view.subviews {
            if let subView = item as? LLProgressHUD {
                subView.hide()
                subView.removeFromSuperview()
                hud = subView
            }
        }
        return hud
    }
}





// MARK:- 扩展视图方法，自带指示器
var key_hud = "key_hud"
extension UIView {
    // 指示器
    var HUD:LLProgressHUD? {
        set {
            objc_setAssociatedObject(self, &key_hud, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            var tmp = objc_getAssociatedObject(self, &key_hud) as? LLProgressHUD
            if tmp == nil {
                tmp = LLProgressHUD.show(in: self, animate: false)
                objc_setAssociatedObject(self, &key_hud, tmp, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return tmp
        }
    }
    
}

