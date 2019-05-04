//
//  LLDropBoxView.swift
//  LLPhotosPicker
//
//  Created by LOLITA0164 on 2019/4/15.
//  Copyright © 2019年 LOLITA0164. All rights reserved.
//

import UIKit
import SnapKit

// MARK:- 下拉框视图
class LLDropBoxView: UIView {

    // 定义一个标题和icon
    let titleLabel: UILabel = {
        let tmp = UILabel()
        tmp.font = UIFont.boldSystemFont(ofSize: 17)
        tmp.textColor = UIColor.black
        tmp.textAlignment = .center
        return tmp
    }()
    var iconImageView:UIImageView = UIImageView()
    
    // 背景视图
    lazy var dropBoxBackgroundView: UIButton = {
        let tmp = UIButton()
        tmp.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        tmp.addTarget(self, action: #selector(self.closeActionEvent(sender:)), for: .touchUpInside)
        return tmp
    }()
    
    // 定义一个表格视图，用于显示选项
    lazy var tableView: UITableView = {
        let tmp = UITableView.init(frame: CGRect.zero, style: UITableView.Style.plain)
        tmp.showsVerticalScrollIndicator = false
        tmp.showsHorizontalScrollIndicator = false
        tmp.bounces = false
        tmp.delegate = self
        tmp.dataSource = self
        tmp.tableFooterView = UIView()
        tmp.separatorStyle = .none
        tmp.rowHeight = 55
        tmp.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        tmp.register(LLDropBoxViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        return tmp
    }()
    
    // 点击手势
    var tapSingle:UITapGestureRecognizer?
    
    // 记录展开收起表示
    var isOpen = false
    
    // 数据源
    var options:[LLOption] = []
    
    // 构造器
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(title:String?, icon:UIImage?) {
        let rect = CGRect.init(x: 0, y: 0, width: 100, height: 44)
        super.init(frame: rect)
        let space = CGFloat(5)
        // 背景视图
        let bgView = UIView()
        self.addSubview(bgView)
        // 设置标题
        self.titleLabel.text = title
        bgView.addSubview(self.titleLabel)
        // 设置图标
        self.iconImageView.image = icon
        bgView.addSubview(self.iconImageView)
        // 设置相关约束
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(self.iconImageView.snp.left).offset(-space)
        }
        self.iconImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        bgView.snp.makeConstraints {(make) in
            make.center.equalToSuperview()
            make.height.equalTo(44)
            make.left.equalTo(self.titleLabel.snp.left)
            make.right.equalTo(self.iconImageView.snp.right)
        }
        // 添加单击事件
        self.addTarget(target: self, action: #selector(self.clikActionEvent(sender:)))
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == nil {
            for subView in self.subviews {
                let hitPoint = subView.convert(point, from: self)
                if subView.bounds.contains(hitPoint) {
                    return subView
                }
            }
        }
        return view
    }
    
    // 添加单击事件
    func addTarget(target: Any?, action: Selector?) {
        //单击监听
        self.tapSingle = UITapGestureRecognizer.init(target: target, action: action)
        self.addGestureRecognizer(self.tapSingle!)
    }
    
    // MARK:- 操作事件
    @objc func closeActionEvent(sender:UIButton) {
        self.clikActionEvent(sender: self.tapSingle!)
    }
    @objc func clikActionEvent(sender:UITapGestureRecognizer) {
        self.isOpen = self.iconImageView.transform == .identity
        if self.iconImageView.transform == .identity {
            // 展开
            UIView.animate(withDuration: 0.25) {
                // 旋转图标
                self.iconImageView.transform = self.iconImageView.transform.rotated(by: CGFloat(Double.pi))
                // 透明度更改
                self.dropBoxBackgroundView.alpha = 1
                // 表格视图
                let heigth = CGFloat(self.options.count) * self.tableView.rowHeight
                self.tableView.snp.updateConstraints({ (make) in
                    make.height.equalTo(heigth)
                })
                self.tableView.superview!.layoutIfNeeded()
            }
        } else {
            // 收起
            UIView.animate(withDuration: 0.25) {
                // 旋转图标
                self.iconImageView.transform = .identity
                // 透明度更改
                self.dropBoxBackgroundView.alpha = 0
                // 表格视图
                self.tableView.snp.updateConstraints({ (make) in
                    make.height.equalTo(0)
                })
                self.tableView.superview!.layoutIfNeeded()
            }
        }
    }
}


// MARK:- 扩展实现表格视图的 UITableViewDelegate、UITableViewDataSource
extension LLDropBoxView:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.options.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! LLDropBoxViewCell
        cell.selectionStyle = .none
        let option = self.options[indexPath.row]
        cell.titleLabel.text = option.title
        cell.iconImageView.image = option.icon
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        DispatchQueue.main.async {
            let option = self.options[indexPath.row]
            self.titleLabel.text = option.title
            option.picked?()
            self.clikActionEvent(sender: self.tapSingle!)
        }
    }
}



// MARK:- 扩展一个外部调用的API
extension LLDropBoxView {
    /// 显示在某个视图上
    func showOnView(baseView:UIView, options:[LLOption]) {
        // 添加背景视图
        baseView.addSubview(self.dropBoxBackgroundView)
        self.dropBoxBackgroundView.alpha = 0
        self.dropBoxBackgroundView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        // 记录数据源
        self.options = options
        self.tableView.reloadData()
        // 添加表格视图
        baseView.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(0)
        }
    }
}






// MARK:- 表格的单元格样式
class LLDropBoxViewCell: UITableViewCell {
    // 标题标签
    let titleLabel: UILabel = {
        let tmp = UILabel()
        tmp.textAlignment = .left
        tmp.font = UIFont.boldSystemFont(ofSize: 17)
        return tmp
    }()
    
    // 图片
    let iconImageView: UIImageView = {
        let tmp = UIImageView()
        return tmp
    }()
    
    let bgView: UIView = {
        let tmp = UIView()
        return tmp
    }()
    
    
    // 构造器
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // 添加到视图上
        self.addSubview(self.bgView)
        self.bgView.addSubview(self.titleLabel)
        self.bgView.addSubview(self.iconImageView)
        // 约束
        self.titleLabel.snp.makeConstraints { [weak self] (make) in
            make.right.top.bottom.equalToSuperview()
            make.left.equalTo((self?.iconImageView.snp.right)!).offset(5)
        }
        self.iconImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(20)
            make.left.centerY.equalToSuperview()
        }
        self.bgView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
}





// MARK:- 选项类型
class LLOption: NSObject {
    // 回调
    typealias pickedBlock = ()->Void
    var picked:pickedBlock?
    var title:String?
    var icon:UIImage?
    
    /// 初始化方法
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - icon: 图标
    ///   - picked: 选择回调
    init(title:String?=nil, icon:UIImage?=nil, picked:pickedBlock?) {
        self.title = title
        self.icon = icon
        self.picked = picked
    }
}
