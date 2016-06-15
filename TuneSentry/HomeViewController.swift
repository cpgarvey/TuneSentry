//
//  HomeViewController.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/28/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import UIKit
import CoreData

func < (lhs: Artist, rhs: Artist) -> Bool {
    return lhs.artistName.localizedStandardCompare(rhs.artistName) == .OrderedAscending
}

typealias NewReleaseCheckComplete = (success: Bool, errorString: String?) -> Void

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    var watchlistArtists = [Artist]()
    var newReleases = [NewRelease]()
    
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
        
        cellNib = UINib(nibName: CollectionViewCellIdentifiers.noNewReleasesCollectionCell, bundle: nil)
        mainCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.noNewReleasesCollectionCell)
        
        // set up the flow layout for the collection view cells
        let mainLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        mainLayout.sectionInset = UIEdgeInsets(top: 6, left: 8, bottom: 0, right: 8)
        mainLayout.minimumLineSpacing = 6
        mainLayout.scrollDirection = .Vertical
        mainLayout.headerReferenceSize = CGSize(width: self.view.frame.size.width, height: 90)
        
        let height = 184
        let width = Int(self.view.bounds.size.width - 16)
        print(self.view.bounds.size.width)
        
        mainLayout.itemSize = CGSize(width: width, height: height)
        mainCollectionView.collectionViewLayout = mainLayout
        
        watchlistArtists = fetchAllArtists()
        
        // TO DO: Add fetchResultsController for collection view
    
        fetchCurrentNewReleases()
        checkForNewReleases()
    }
    

    struct CollectionViewCellIdentifiers {
        static let newReleaseCollectionCell = "NewReleaseCollectionCell"
        static let noNewReleasesCollectionCell = "NoNewReleasesCollectionCell"
        static let newReleaseHoldingCollectionCell = "NewReleaseHoldingCollectionCell"
        static let artistWatchlistCell = "ArtistWatchlistCell"
    }
    
    func fetchAllArtists() -> [Artist] {
        let fetchRequest = NSFetchRequest(entityName: "Artist")
        
        do {
            var artists = try sharedContext.executeFetchRequest(fetchRequest) as! [Artist]
            artists.sortInPlace(<)
            return artists
        } catch _ {
            return [Artist]()
        }
    }
    
    
    func fetchCurrentNewReleases() {
        
        var newReleases = [NewRelease]()
        
        // first pull all new releases that are in Core Data
        var newReleasesFromCoreData = [NewRelease]()
        let fetchRequest = NSFetchRequest(entityName: "NewRelease")
        
        do {
            newReleasesFromCoreData = try sharedContext.executeFetchRequest(fetchRequest) as! [NewRelease]
        } catch _ {
            // do nothing...
        }
        
        
        if !newReleasesFromCoreData.isEmpty {
            for release in newReleasesFromCoreData {
                newReleases.append(release)
            }
        }
        
        // sort in place the newReleases?
        self.newReleases = newReleases
    }
    
    func checkForNewReleases() {
        
        for artist in watchlistArtists {
            
            artist.checkForNewRelease() { success, errorString in
                
                if success {
                    performOnMain {
                        CoreDataStackManager.sharedInstance().saveContext()
                    }
                }
            }
        
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
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {

        if collectionView == mainCollectionView {
            
            switch kind {
                
            case UICollectionElementKindSectionHeader:
                
                let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "HomeHeaderView", forIndexPath: indexPath) as! HomeHeaderView
                
                if indexPath.section == 0 {
                    headerView.header.text = "New Releases:"
                } else {
                    headerView.header.text = "Watchlist Artists:"
                }
                return headerView
            default:
                assert(false, "Unexpected element kind")
            }
            
        } else {
            let headerView = UICollectionReusableView()
            return headerView
        }
        
    }

    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
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
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if collectionView == mainCollectionView {
            
            if indexPath.section == 0 {
                
                if newReleases.isEmpty {
                    
                    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCellIdentifiers.noNewReleasesCollectionCell,
                                                                                     forIndexPath: indexPath)
                    return cell
                } else {
                    
                    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCellIdentifiers.newReleaseHoldingCollectionCell,
                                                                                     forIndexPath: indexPath)
                    return cell
                }
                
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
                                                                             forIndexPath: indexPath) as! NewReleaseCollectionCell
            
            let newRelease = newReleases[indexPath.row]
            cell.artistName.text = newRelease.artist.artistName
            cell.newReleaseTitle.text = newRelease.collectionName
            cell.newReleaseImage.image = UIImage(data: (newRelease.newReleaseArtwork))
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
