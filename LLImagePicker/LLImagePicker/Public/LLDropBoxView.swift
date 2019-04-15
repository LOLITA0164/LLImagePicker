//
//  LLDropBoxView.swift
//  LLImagePicker
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
    
    // 定义一个表格视图，用于显示选项
    lazy var tableView: UITableView = {
        let tmp = UITableView.init(frame: CGRect.zero, style: UITableView.Style.plain)
        tmp.showsVerticalScrollIndicator = false
        tmp.showsHorizontalScrollIndicator = false
        tmp.bounces = false
        tmp.delegate = self
        tmp.dataSource = self
        tmp.tableFooterView = UIView()
        tmp.separatorInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        tmp.rowHeight = 55
        tmp.backgroundColor = UIColor.black.withAlphaComponent(0.5)
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
        super.init(frame: CGRect.zero)
        let space = CGFloat(5)
        // 背景视图
        let bgView = UIView()
        // 设置标题
        if let title = title {
            self.titleLabel.text = title
            self.titleLabel.sizeToFit()
            bgView.addSubview(self.titleLabel)
        }
        // 设置图标
        if let icon = icon {
            self.iconImageView.image = icon
            self.iconImageView.frame = CGRect.init(origin: CGPoint.init(x: self.titleLabel.bounds.width+space, y: 0), size: CGSize.init(width: 20, height: 20))
            bgView.addSubview(self.iconImageView)
        }
        // 设置背景视图的frame
        bgView.frame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: self.titleLabel.bounds.width+self.iconImageView.bounds.width+space, height: max(self.titleLabel.bounds.height, self.iconImageView.bounds.height)))
        // 当前视图的 size 是 zero，会影响下面的手势
        self.frame = CGRect.init(origin: .zero, size: bgView.bounds.size)
        bgView.center = CGPoint.init(x: self.bounds.width/2.0, y: self.bounds.height/2.0)
        // 设置标题标签的位置
        self.titleLabel.center = CGPoint.init(x: self.titleLabel.bounds.width/2.0, y: bgView.bounds.height/2.0)
        // 设置图标的位置
        self.iconImageView.center = CGPoint.init(x: self.iconImageView.bounds.width/2.0+self.titleLabel.bounds.width, y: bgView.bounds.height/2.0)
        self.addSubview(bgView)
        
        // 添加单击事件
        self.addTarget(target: self, action: #selector(self.clikActionEvent(sender:)))
        
    }
    
    // 添加单击事件
    func addTarget(target: Any?, action: Selector?) {
        //单击监听
        self.tapSingle = UITapGestureRecognizer.init(target: target, action: action)
        self.addGestureRecognizer(self.tapSingle!)
    }
    
    // MARK:- 操作事件
    @objc func clikActionEvent(sender:UITapGestureRecognizer) {
        self.isOpen = self.iconImageView.transform == .identity
        if self.iconImageView.transform == .identity {
            // 展开
            UIView.animate(withDuration: 0.15) {
                self.iconImageView.transform = self.iconImageView.transform.rotated(by: CGFloat(Double.pi))
                let height = CGFloat(self.options.count) * self.tableView.rowHeight
                self.tableView.snp.updateConstraints({ (make) in
                    make.height.equalTo(height)
                })
                self.tableView.layoutIfNeeded()
            }
        } else {
            // 收起
            UIView.animate(withDuration: 0.15) {
                self.iconImageView.transform = .identity
                self.tableView.snp.updateConstraints({ (make) in
                    make.height.equalTo(0)
                })
                self.tableView.layoutIfNeeded()
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
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        }
        cell?.selectionStyle = .none
        let option = self.options[indexPath.row]
        cell?.textLabel?.text = option.title
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let option = self.options[indexPath.row]
        option.picked?()
    }
}



// MARK:- 扩展一个外部调用的API
extension LLDropBoxView {
    
    func showOnView(baseView:UIView, options:[LLOption]) {
        // 记录数据源
        self.options = options
        // 添加表格视图
        baseView.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(0)
        }
        self.tableView.reloadData()
    }
    
    // 新增显示方法
//    func showOnView(baseView:UIView, title:String?, icon:UIImage?) -> LLDropBoxView {
//        let dropBoxView = LLDropBoxView()
//        dropBoxView.setup(title: title, icon: icon)
//        return dropBoxView
//    }
}






// MARK:- 表格的单元格样式






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
