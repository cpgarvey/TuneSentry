//
//  NewReleaseHoldingCollectionCell.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/30/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import Foundation
import UIKit

class NewReleaseHoldingCollectionCell: UICollectionViewCell {
    
// citation: https://ashfurrow.com/blog/putting-a-uicollectionview-in-a-uitableviewcell-in-swift/
    
    @IBOutlet weak var holdingCollectionView: UICollectionView!
    
    func setCollectionViewDataSourceDelegate
        <D: protocol<UICollectionViewDataSource, UICollectionViewDelegate>>
        (dataSourceDelegate: D, forRow row: Int) {
        
        holdingCollectionView.delegate = dataSourceDelegate
        holdingCollectionView.dataSource = dataSourceDelegate
        holdingCollectionView.tag = row
        holdingCollectionView.reloadData()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
        holdingCollectionView.backgroundColor = UIColor.clearColor()
        
        let cellNib = UINib(nibName: CollectionViewCellIdentifiers.newReleaseCollectionCell, bundle: nil)
        holdingCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.newReleaseCollectionCell)
        
    }
    
    struct CollectionViewCellIdentifiers {
        static let newReleaseCollectionCell = "NewReleaseCollectionCell"
        static let noNewReleasesCell = "NoNewReleasesCell"
    }
    
}

extension NewReleaseHoldingCollectionCell: UICollectionViewDelegate {
    
    func viewDidLayoutSubviews() {
        
        let newReleaseLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        newReleaseLayout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        newReleaseLayout.minimumInteritemSpacing = 5
        newReleaseLayout.scrollDirection = .Horizontal
        
//        let newReleaseHeight = 182
//        let newReleaseWidth = 128
//        
//        newReleaseLayout.itemSize = CGSize(width: newReleaseWidth, height: newReleaseHeight)
        holdingCollectionView.collectionViewLayout = newReleaseLayout
        
    }

    
}
