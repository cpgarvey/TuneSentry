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
    @IBOutlet weak var artistCollectionView: UICollectionView!
    
    var newReleases = true
    var watchlistArtists = [Artist]()

    override func viewDidLoad() {
        super.viewDidLoad()

        newReleaseCollectionView.backgroundColor = UIColor.clearColor()
        artistCollectionView.backgroundColor = UIColor.clearColor()
        
        // load the nibs for the new releases collection view
        var cellNib = UINib(nibName: CollectionViewCellIdentifiers.newReleaseCell, bundle: nil)
        newReleaseCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.newReleaseCell)
        
        cellNib = UINib(nibName: CollectionViewCellIdentifiers.noNewReleasesCell, bundle: nil)
        newReleaseCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.noNewReleasesCell)
        
        // load the nibs for the artist collection view
        cellNib = UINib(nibName: CollectionViewCellIdentifiers.artistCell, bundle: nil)
        artistCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.artistCell)
        
    }


    struct CollectionViewCellIdentifiers {
        static let newReleaseCell = "NewReleaseCell"
        static let noNewReleasesCell = "NoNewReleasesCell"
        static let artistCell = "ArtistCell"
    }
    
    
    // MARK: Collection View Layouts
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // set up the new releases collection view
        let newReleaseLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        newReleaseLayout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        newReleaseLayout.minimumInteritemSpacing = 5
        newReleaseLayout.scrollDirection = .Horizontal
        
        let newReleaseHeight = 124
        let newReleaseWidth = newReleases ? 100 : 238
        
        newReleaseLayout.itemSize = CGSize(width: newReleaseWidth, height: newReleaseHeight)
        newReleaseCollectionView.collectionViewLayout = newReleaseLayout
        
        // set up the artists collection view
        let artistLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        artistLayout.sectionInset = UIEdgeInsets(top: 5, left: 7, bottom: 0, right: 7)
        artistLayout.minimumInteritemSpacing = 8
        artistLayout.minimumLineSpacing = 6
        artistLayout.scrollDirection = .Vertical
        
        print(artistCollectionView.frame.size.width)
        let artistCollectionViewCellHeight = 182
        let artistCollectionViewCellWidth = Int((artistCollectionView.frame.size.width - 30) / 3)
        
        artistLayout.itemSize = CGSize(width: artistCollectionViewCellWidth, height: artistCollectionViewCellHeight)
        artistCollectionView.collectionViewLayout = artistLayout
        
    }
    
    
}


extension HomeViewController: UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == newReleaseCollectionView {
            if !newReleases {
                return 1
            } else {
                return 10
            }
        } else {
            if watchlistArtists.isEmpty {
                return 1
            } else {
                return 25
            }
        }
    }
}


extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        if collectionView == newReleaseCollectionView {
            
            if !newReleases {
                return newReleaseCollectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCellIdentifiers.noNewReleasesCell, forIndexPath: indexPath)
            } else {
                return newReleaseCollectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCellIdentifiers.newReleaseCell, forIndexPath: indexPath)
            }
            
        } else {
            
            if watchlistArtists.isEmpty {
                // show the cell that says no artists watching right now...
                return UICollectionViewCell()
            } else {
                return artistCollectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCellIdentifiers.artistCell, forIndexPath: indexPath)
            }
            
        }
    }
}