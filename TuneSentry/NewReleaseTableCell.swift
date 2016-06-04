//
//  NewReleaseTableCell.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/30/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import Foundation
import UIKit

class NewReleaseTableCell: UITableViewCell {
    
// citation: https://ashfurrow.com/blog/putting-a-uicollectionview-in-a-uitableviewcell-in-swift/
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    func setCollectionViewDataSourceDelegate
        <D: protocol<UICollectionViewDataSource, UICollectionViewDelegate>>
        (dataSourceDelegate: D, forRow row: Int) {
        
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        collectionView.reloadData()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
        collectionView.backgroundColor = UIColor.clearColor()
        
        let cellNib = UINib(nibName: CollectionViewCellIdentifiers.newReleaseCollectionCell, bundle: nil)
        collectionView.registerNib(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.newReleaseCollectionCell)
        
    }
    
    struct CollectionViewCellIdentifiers {
        static let newReleaseCollectionCell = "NewReleaseCollectionCell"
        static let noNewReleasesCell = "NoNewReleasesCell"
    }
    
}

extension NewReleaseTableCell: UICollectionViewDelegate {
    
    func viewDidLayoutSubviews() {
        
        let newReleaseLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        newReleaseLayout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        newReleaseLayout.minimumInteritemSpacing = 5
        newReleaseLayout.scrollDirection = .Horizontal
        
        let newReleaseHeight = 182
        let newReleaseWidth = 128
        
        newReleaseLayout.itemSize = CGSize(width: newReleaseWidth, height: newReleaseHeight)
        collectionView.collectionViewLayout = newReleaseLayout
        
    }

    
}
