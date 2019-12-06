//
//  CircularLayoutLayout.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/12/5.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit

internal final class CircularLayoutLayoutController: BaseViewController {

    final class CircularLayoutCell: UICollectionViewCell {
        override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
            super.apply(layoutAttributes)
            let circularlayoutAttributes = layoutAttributes as! CircularCollectionViewLayout.CircularCollectionViewLayoutAttributes
            self.layer.anchorPoint = circularlayoutAttributes.anchorPoint
            self.center.y += (circularlayoutAttributes.anchorPoint.y - 0.5) * self.bounds.height
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        $0.register(CircularLayoutCell.self, forCellWithReuseIdentifier: "Cell")
        $0.delegate = self
        $0.backgroundColor = UIColor.white
        $0.dataSource = self
        self.view.addSubview($0)
        return $0
    }(UICollectionView(frame: CGRect(x: 0, y: 0, width: iphone_width, height: iphone_height - navigationBar_height), collectionViewLayout: {
        $0.itemSize = CGSize(width: 100, height: 100)
        $0.radius = 200
        return $0
    }(CircularCollectionViewLayout())))
    
    var colors: [UIColor] = [.black, .red, .brown, .darkGray, .lightGray, .systemPink, .purple, .orange]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "CircularLayoutLayout"
        self.collectionView.reloadData()
    }
}

extension CircularLayoutLayoutController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.contentView.backgroundColor = self.colors[indexPath.item]
        return cell
    }
}
