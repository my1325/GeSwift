//
//  CycleScrollViewController.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/9/12.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit

internal final class CycleScrollViewController: BaseViewController {

    private lazy var cycleScrollView: CycleScrollView = {
        $0.delegate = self
        $0.dataSource = self
        $0.isHidePageControlWhenSinglePage = true
        $0.pageControl = SizeFitPageControl()
        $0.scrollDirection = .horizontal
        $0.scrollTimeInterval = 5
        self.view.addSubview($0)
        return $0
    }(CycleScrollView(frame: CGRect(x: 0, y: 10, width: iphone_width, height: 200)))
    
    private lazy var verticleCycleScrollView: CycleScrollView = {
        $0.delegate = self
        $0.dataSource = self
        $0.pageControl = CircleScalePageControl()
        $0.isHidePageControlWhenSinglePage = true
        $0.scrollDirection = .horizontal
        $0.scrollTimeInterval = 5
        self.view.addSubview($0)
        return $0
    }(CycleScrollView(frame: CGRect(x: 0, y: 230, width: iphone_width, height: 200)))
    
    let images: [String] = ["http://pic25.nipic.com/20121112/9252150_150552938000_2.jpg",
                            "http://gss0.baidu.com/-fo3dSag_xI4khGko9WTAnF6hhy/lvpics/w=600/sign=1350023d79899e51788e391472a5d990/b21bb051f819861810d03e4448ed2e738ad4e65f.jpg",
                            "http://pic51.nipic.com/file/20141025/8649940_220505558734_2.jpg",
    "http://pic40.nipic.com/20140424/12259251_002036722178_2.jpg",
    "http://pic31.nipic.com/20130801/11604791_100539834000_2.jpg",
    "http://pic44.nipic.com/20140719/2531170_081420875000_2.jpg"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "CycleScrollViewController"
        self.cycleScrollView.reloadData()
        self.verticleCycleScrollView.reloadData()
    }
}

extension CycleScrollViewController: CycleScrollViewDelegate, CycleScrollViewDataSource {
    
    func numberOfItemsIn(scrollView: CycleScrollView) -> Int {
        return images.count
    }
    
    func scrollView(_ scrollView: CycleScrollView, imageURLAtIndex index: Int) -> URL? {
        return URL(string: images[index])
    }
}
