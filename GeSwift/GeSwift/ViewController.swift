//
//  ViewController.swift
//  GeSwift
//
//  Created by my on 2018/6/20.
//  Copyright © 2018年 my. All rights reserved.
//

import SnapKit
import UIKit
import WCDBSwift
import RxSwift
import Combine
// import IJKMediaFramework

internal class BaseViewController: UIViewController, UIGestureRecognizerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_back_white"), style: .plain, target: self, action: #selector(self.popViewController))
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = .init(rawValue: 0)
        if #available(iOS 11.0, *) {
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.view.backgroundColor = UIColor.white
        
    }
    
    @objc func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }
}

internal final class ViewController: BaseViewController {
    lazy var tableView = UITableView(frame: CGRect.zero, style: UITableView.Style.plain).ge {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.tableFooterView = UIView()
        $0.delegate = self
        $0.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        self.view.addSubview($0)
        $0.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
    }
    
    struct ViewController {
        var name: String
        var controller: UIViewController
    }

    let viewControllers: [ViewController] = [ViewController(name: "HorizontalViewController", controller: HorizontalViewController()),
                                             ViewController(name: "ScanViewController", controller: ScanViewController()),
                                             ViewController(name: "CycleScrollViewController", controller: CycleScrollViewController()),
                                             ViewController(name: "LayoutViewController", controller: LayoutViewController()),
                                             ViewController(name: "CircularLayoutLayoutController", controller: CircularLayoutLayoutController()),
                                             ViewController(name: "InputFieldViewController", controller: InputFieldViewController())]
//                                     ViewController(name: "IJKPlayerViewController", controller: IJKPlayerViewController())]
    let dataSource = TableViewDataSource<SectionModel<String, ViewController>>(configureCell: { _, tableView, indexPath, controller in
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
            cell?.textLabel?.textColor = "666666".ge.asColor
            cell?.accessoryType = .disclosureIndicator
        }
        cell?.textLabel?.text = "\(indexPath.row + 1)、\(controller.name)"
        return cell!
    })

    let driver = DataSourceDriver<[ViewController]>(initialValue: [])
    
    let plist = Plist.default

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "GeSwift-Examples"
        self.navigationItem.leftBarButtonItem = nil
        self.view.backgroundColor = UIColor.white

//        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
//        self.driver.map({ [SectionModel(section: "", items: $0)] }).bind(to: self.tableView.ge.dataSource(reuseIdentifier: "Cell", cell: UITableViewCell.self))({ tableView, item, cell in
//            cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
//            cell.textLabel?.textColor = "666666".ge.asColor
//            cell.accessoryType = .disclosureIndicator
//            cell.textLabel?.text = "\(item.name)"
//        })
                
        self.driver.map({ [SectionModel(section: "", items: $0)] }).bind(to: self.tableView.ge.dataSource(dataSource))
        self.driver.accept(self.viewControllers)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.pushViewController(viewControllers[indexPath.item].controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.ge.height(forIndexPath: indexPath)
    }
}
