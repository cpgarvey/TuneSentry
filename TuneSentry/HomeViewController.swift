//
//  HomeViewController.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/28/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    var newReleases = true
    var watchlistArtists = [Artist]()

    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mainCollectionView.backgroundColor = UIColor.clearColor()
        
        var cellNib = UINib(nibName: CollectionViewCellIdentifiers.newReleaseHoldingCollectionCell, bundle: nil)
        mainCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.newReleaseHoldingCollectionCell)
        
        cellNib = UINib(nibName: CollectionViewCellIdentifiers.artistWatchlistCell, bundle: nil)
        mainCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.artistWatchlistCell)
        
        // set the contentInset so that the first rows of the table always fully appears: 44 pts (search bar)
        mainCollectionView.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)
        
        // set up the flow layout for the collection view cells
        let mainLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        mainLayout.sectionInset = UIEdgeInsets(top: 6, left: 8, bottom: 0, right: 8)
        mainLayout.minimumLineSpacing = 6
        mainLayout.scrollDirection = .Vertical
        
        let height = 184
        let width = Int(self.view.bounds.size.width - 16)
        print(self.view.bounds.size.width)
        
        mainLayout.itemSize = CGSize(width: width, height: height)
        mainCollectionView.collectionViewLayout = mainLayout
        
        watchlistArtists = fetchAllArtists()
        
        // TO DO: Add fetchResultsController for collection view
    
    }
    

    struct CollectionViewCellIdentifiers {
        static let newReleaseCollectionCell = "NewReleaseCollectionCell"
        static let noNewReleasesCell = "NoNewReleasesCell"
        static let newReleaseHoldingCollectionCell = "NewReleaseHoldingCollectionCell"
        static let artistWatchlistCell = "ArtistWatchlistCell"
    }
    
    func fetchAllArtists() -> [Artist] {
        let fetchRequest = NSFetchRequest(entityName: "Artist")
        
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [Artist]
        } catch _ {
            return [Artist]()
        }
    }
    

    
}


extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if collectionView == mainCollectionView {
            return 2
        } else {
            return 1
        }
    }
    
    func collectionView(collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == mainCollectionView {
            if section == 0 {
                return 1
            } else {
                return watchlistArtists.count
            }
        } else {
            return 10
        }
        
    }
    
    func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if collectionView == mainCollectionView {
            
            if indexPath.section == 0 {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCellIdentifiers.newReleaseHoldingCollectionCell,
                                                                                 forIndexPath: indexPath)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCellIdentifiers.artistWatchlistCell, forIndexPath: indexPath) as! ArtistWatchlistCell
                let artist = watchlistArtists[indexPath.row]
                cell.artist = artist
                cell.artistNameLabel.text = artist.artistName
                cell.genreLabel.text = artist.primaryGenreName
                cell.mostRecentArtwork.image = UIImage(data: (artist.mostRecentArtwork))
                cell.artistId.text = String(format: "Artist Id: %d", artist.artistId)
                return cell
            }
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCellIdentifiers.newReleaseCollectionCell,
                                                                             forIndexPath: indexPath)
            return cell
        }
        
    }
    
    func collectionView(collectionView: UICollectionView,
                        willDisplayCell cell: UICollectionViewCell,
                                        forItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == mainCollectionView {
            
            guard let newReleaseHoldingCollectionCell = cell as? NewReleaseHoldingCollectionCell else { return }
            
            newReleaseHoldingCollectionCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        }
    }
}
