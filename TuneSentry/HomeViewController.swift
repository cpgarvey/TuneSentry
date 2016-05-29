//
//  HomeViewController.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/28/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var newReleaseCollectionView: UICollectionView!
    
    var newReleases = true

    override func viewDidLoad() {
        super.viewDidLoad()

        newReleaseCollectionView.backgroundColor = UIColor.clearColor()
        
        // load the nibs for the new releases collection view
        var cellNib = UINib(nibName: CollectionViewCellIdentifiers.newReleaseCell, bundle: nil)
        newReleaseCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.newReleaseCell)
        
        cellNib = UINib(nibName: CollectionViewCellIdentifiers.noNewReleasesCell, bundle: nil)
        newReleaseCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.noNewReleasesCell)
        
        // load the nibs for the artist collection view
        
        
    }


    struct CollectionViewCellIdentifiers {
        static let newReleaseCell = "NewReleaseCell"
        static let noNewReleasesCell = "NoNewReleasesCell"
    }
    
    
    // MARK: Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let newReleaseLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        newReleaseLayout.minimumInteritemSpacing = 5
        newReleaseLayout.scrollDirection = .Horizontal
        
        let height = 124
        let width = newReleases ? 100 : 238
        
        newReleaseLayout.itemSize = CGSize(width: width, height: height)
        newReleaseCollectionView.collectionViewLayout = newReleaseLayout
    }
    
    
}


extension HomeViewController: UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if !newReleases {
            return 1
        } else {
            return 10
        }
    }
}


extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        
        if !newReleases {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCellIdentifiers.noNewReleasesCell, forIndexPath: indexPath)
        } else {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCellIdentifiers.newReleaseCell, forIndexPath: indexPath)
        }
        
        return cell
        
    }
}