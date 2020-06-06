//
//  ViewController.swift
//  GeSwift
//
//  Created by my on 2018/6/20.
//  Copyright © 2018年 my. All rights reserved.
//

import UIKit
import SnapKit
import WCDBSwift
//import IJKMediaFramework

internal final class WorkItem: Table, TableCodable {
    
    static var tableName: String = "WorkItem"

    var identifier: Int?
    
    var actualStartTime: TimeInterval?
    var actualEndTime: TimeInterval?
    
    var expectedStartTime: TimeInterval
    var expectedEndTime: TimeInterval
    var createTime: TimeInterval
    var content: String
    var extralCompleteContent: String?
    var remark: String?
    
    var isAutoIncrement: Bool = true // 用于定义是否使用自增的方式插入
    var lastInsertedRowID: Int64 = 0 // 用于获取自增插入后的主键值
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = WorkItem
        static let objectRelationalMapping = TableBinding(WorkItem.CodingKeys.self)
        
        case actualStartTime = "actual_start_time"
        case actualEndTime = "actual_end_time"
        case expectedStartTime = "expected_start_time"
        case expectedEndTime = "expected_end_time"
        case createTime = "create_time"
        case content = "content"
        case extralCompleteContent = "extral_complete_content"
        case remark = "remark"
        case identifier = "identifier"
    }
    
    init(content: String, expectedStartTime: TimeInterval, expectedEndTime: TimeInterval) {
        self.expectedEndTime = expectedEndTime
        self.expectedStartTime = expectedStartTime
        self.content = content
        self.createTime = Date().timeIntervalSince1970
    }
}

internal class BaseViewController: UIViewController, UIGestureRecognizerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_back_white"), style: .plain, target: self, action: #selector(popViewController))
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = .init(rawValue: 0)
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIColor.white
    }
    
    @objc func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }
}

internal final class ViewController: BaseViewController {
    
    lazy var tableView: UITableView = UITableView(frame: CGRect.zero, style: UITableView.Style.plain).ge {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.tableFooterView = UIView()
        $0.delegate = self
        $0.dataSource = self
        $0.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        ["", ""].bindItems(to: $0.ge.items(reuseIdentifier: "UITableViewCell", cellType: UITableViewCell.self))({ tableView, item, cell in

        })
        
//        [[""], [""]].bindSectionItems(to: $0.ge.items(reuseIdentifier: "UITableViewCell", cellType: UITableViewCell.self))({ tableView, item, cell in
//            print(item)
//        })
        
        [[""], [""]].bindSectionItems(to: $0.ge.sectionItems(reuseIdentifier: "UITableViewCell", cellType: UITableViewCell.self))({ tableView, item ,cell in
            cell.textLabel?.text = item
        })
        
        self.view.addSubview($0)
        $0.snp.makeConstraints({ (make) in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        })
    }
//    lazy var tableView: UITableView = {
//        $0.translatesAutoresizingMaskIntoConstraints = false
//        $0.tableFooterView = UIView()
//        $0.delegate = self
//        $0.dataSource = self
//        $0.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        self.view.addSubview($0)
//        $0.snp.makeConstraints({ (make) in
//            make.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
//        })
//        return $0
//    }(UITableView(frame: CGRect.zero, style: UITableView.Style.plain))
    
    struct ViewController {
        var name: String
        var controller: UIViewController
    }
    let viewControllers: [ViewController] = [ViewController(name: "HorizontalViewController", controller: HorizontalViewController()),
                                     ViewController(name: "ScanViewController", controller: ScanViewController()),
                                     ViewController(name: "CycleScrollViewController", controller: CycleScrollViewController()),
                                     ViewController(name: "LayoutViewController", controller: LayoutViewController()),
                                     ViewController(name: "CircularLayoutLayoutController", controller: CircularLayoutLayoutController()),]
//                                     ViewController(name: "IJKPlayerViewController", controller: IJKPlayerViewController())]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "GeSwift-Examples"
        self.navigationItem.leftBarButtonItem = nil
        self.view.backgroundColor = UIColor.white
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewControllers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
            cell?.textLabel?.textColor = "666666".ge.asColor
            cell?.accessoryType = .disclosureIndicator
        }
        cell?.textLabel?.text = "\(indexPath.row + 1)、\(viewControllers[indexPath.row].name)"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.pushViewController(viewControllers[indexPath.row].controller, animated: true)
    }
}
