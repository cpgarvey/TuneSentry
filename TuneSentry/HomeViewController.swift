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
    @IBOutlet weak var tableView: UITableView!
    
    var newReleases = true
    var watchlistArtists = [Artist]()

    override func viewDidLoad() {
        super.viewDidLoad()

//        newReleaseCollectionView.backgroundColor = UIColor.clearColor()
//        artistCollectionView.backgroundColor = UIColor.clearColor()
        
        
        // set the contentInset so that the first rows of the table always fully appears: 44 pts (search bar)
        tableView.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)
        
//        // load the nibs for the new releases collection view
//        var cellNib = UINib(nibName: CollectionViewCellIdentifiers.newReleaseCollectionCell, bundle: nil)
//        newReleaseCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.newReleaseCollectionCell)
//        
//        cellNib = UINib(nibName: CollectionViewCellIdentifiers.noNewReleasesCell, bundle: nil)
//        newReleaseCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.noNewReleasesCell)
//        
        let cellNib = UINib(nibName: TableViewCellIdentifiers.newReleaseTableCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.newReleaseTableCell) 
        

        
        
//        // load the nibs for the artist collection view
//        cellNib = UINib(nibName: CollectionViewCellIdentifiers.artistCell, bundle: nil)
//        artistCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.artistCell)
        
        
        
    }


    struct CollectionViewCellIdentifiers {
        static let newReleaseCollectionCell = "NewReleaseCollectionCell"
        static let noNewReleasesCell = "NoNewReleasesCell"
        static let artistCell = "ArtistCell"
    }
    
    struct TableViewCellIdentifiers {
        static let newReleaseTableCell = "NewReleaseTableCell"
    }
    

    // MARK: - Table View Delegate and Data Source
    
    func tableView(tableView: UITableView,
                            willDisplayCell cell: UITableViewCell,
                                            forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let tableViewCell = cell as? NewReleaseTableCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
    }
    
    func tableView(tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView,
                            cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.newReleaseTableCell, forIndexPath: indexPath)
        
    }
    
    
    // MARK: Collection View Layouts
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        
//        // set up the new releases collection view
//        let newReleaseLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//        newReleaseLayout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
//        newReleaseLayout.minimumInteritemSpacing = 5
//        newReleaseLayout.scrollDirection = .Horizontal
//        
//        let newReleaseHeight = 182
//        let newReleaseWidth = 128
//        
//        newReleaseLayout.itemSize = CGSize(width: newReleaseWidth, height: newReleaseHeight)
//        newReleaseCollectionView.collectionViewLayout = newReleaseLayout
//        
//        // set up the artists collection view
//        let artistLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//        artistLayout.sectionInset = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 7)
//        artistLayout.minimumInteritemSpacing = 8
//        artistLayout.minimumLineSpacing = 6
//        artistLayout.scrollDirection = .Vertical
//        
//        print(artistCollectionView.frame.size.width)
//        let artistCollectionViewCellHeight = 182
//        let artistCollectionViewCellWidth = Int((artistCollectionView.frame.size.width - 30) / 3)
//        
//        artistLayout.itemSize = CGSize(width: artistCollectionViewCellWidth, height: artistCollectionViewCellHeight)
//        artistCollectionView.collectionViewLayout = artistLayout
//        
//    }
    
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        return 10
    }
    
    func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCellIdentifiers.newReleaseCollectionCell,
                                                                         forIndexPath: indexPath)
        
        return cell
    }
}


//extension HomeViewController: UICollectionViewDelegate {
//    
//    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
//        return 1
//    }
//    
//    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        
//        if collectionView == newReleaseCollectionView {
//            if !newReleases {
//                return 1
//            } else {
//                return 10
//            }
//        } else {
//            if watchlistArtists.isEmpty {
//                return 25
//            } else {
//                return 25
//            }
//        }
//    }
//}
//
//
//extension HomeViewController: UICollectionViewDataSource {
//    
//    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        
//        if collectionView == newReleaseCollectionView {
//            
//            if !newReleases {
//                return newReleaseCollectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCellIdentifiers.noNewReleasesCell, forIndexPath: indexPath)
//            } else {
//                return newReleaseCollectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCellIdentifiers.newReleaseCollectionCell, forIndexPath: indexPath)
//            }
//            
//        } else {
//            
//            if watchlistArtists.isEmpty {
//                // show the cell that says no artists watching right now...
//                return artistCollectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCellIdentifiers.artistCell, forIndexPath: indexPath)
//            } else {
//                return artistCollectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCellIdentifiers.artistCell, forIndexPath: indexPath)
//            }
//            
//        }
//    }
//}