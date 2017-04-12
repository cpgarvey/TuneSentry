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

    // MARK: - Properties
    
    @IBOutlet weak var holdingCollectionView: UICollectionView!
    
    struct CollectionViewCellIdentifiers {
        static let newReleaseCollectionCell = "NewReleaseCollectionCell"
    }

    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
        holdingCollectionView.backgroundColor = UIColor.clear
        
        let cellNib = UINib(nibName: CollectionViewCellIdentifiers.newReleaseCollectionCell, bundle: nil)
        holdingCollectionView.register(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.newReleaseCollectionCell)
        
    }

    
    // MARK: - Setting the Collection View Delegate
    
    // citation: https://ashfurrow.com/blog/putting-a-uicollectionview-in-a-uitableviewcell-in-swift/
    func setCollectionViewDataSourceDelegate
        <D: UICollectionViewDataSource & UICollectionViewDelegate>
        (_ dataSourceDelegate: D, forRow row: Int) {
        
        holdingCollectionView.delegate = dataSourceDelegate
        holdingCollectionView.dataSource = dataSourceDelegate
        holdingCollectionView.tag = row
        holdingCollectionView.reloadData()
    }
    
}

extension NewReleaseHoldingCollectionCell: UICollectionViewDelegate {
    
    func viewDidLayoutSubviews() {
        
        let newReleaseLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        newReleaseLayout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        newReleaseLayout.minimumInteritemSpacing = 5
        newReleaseLayout.scrollDirection = .horizontal
        holdingCollectionView.collectionViewLayout = newReleaseLayout
        
    }

}
