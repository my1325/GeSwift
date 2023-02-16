//
//  LayoutViewController.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/12/5.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit

internal final class LayoutViewController: BaseViewController {
    
    final class TestCell: UICollectionViewCell {}

    @IBOutlet weak var simpleScaleCollectionView: UICollectionView! {
        didSet {
            self.simpleScaleCollectionView.backgroundColor = UIColor.green
            self.simpleScaleCollectionView.register(TestCell.self, forCellWithReuseIdentifier: "TestCell")
        }
    }
    
    @IBOutlet weak var circularRotatedCollectionView: UICollectionView! {
        didSet {
            self.circularRotatedCollectionView.register(TestCell.self, forCellWithReuseIdentifier: "TestCell")
        }
    }
    
    @IBOutlet weak var simpleScaleLayout: FoldTransitionLayout! {
        didSet {
            self.simpleScaleLayout.itemSize = CGSize(width: 200, height: (iphone_height - navigationBar_height - 60) / 2 - 60)
            self.simpleScaleLayout.scaleOffset = 50
        }
    }
    
    @IBOutlet weak var circularRotatedLayout: SimpleScaleCollectionViewLayout! {
        didSet {
            self.circularRotatedLayout.itemSize = CGSize(width: 270, height: (iphone_height - navigationBar_height - 60) / 2)
            self.circularRotatedLayout.scrollDirection = .horizontal
            self.circularRotatedLayout.minimumLineSpacing = 26
            self.circularRotatedLayout.minimumInteritemSpacing = 26
//            self.circularRotatedLayout.scaleOffset = 50
            self.circularRotatedLayout.sectionInset = UIEdgeInsets(top: 0, left: (iphone_width - 270) * 0.5, bottom: 0, right: (iphone_width - 270) * 0.5)
//            self.circularRotatedLayout.itemSize = CGSize(width: 200, height: (iphone_height - navigationBar_height - 60) / 2 - 60)
//            self.circularRotatedLayout.offsetAngle = CGFloat(Double.pi / 5)
        }
    }
    
    var colors: [UIColor] = [.black, .red, .brown, .darkGray, .lightGray, .systemPink, .purple, .orange]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ///
        self.title = "LayoutViewController"
        self.simpleScaleCollectionView.reloadData()
        self.circularRotatedCollectionView.reloadData()
    }
}

extension LayoutViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TestCell", for: indexPath)
        cell.contentView.backgroundColor = self.colors[indexPath.item]
        return cell
    }
}
