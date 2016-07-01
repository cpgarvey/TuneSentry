//
//  HomeViewController.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/28/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import UIKit
import CoreData


class HomeViewController: UIViewController, ArtistWatchlistCellDelegate, ArtistDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    let search = AppleClient()
    
    /* Variable properties to keep track of insertions, deletions, and updates */
    var insertedIndexPathsForTracker: [NSIndexPath]!
    var deletedIndexPathsForTracker: [NSIndexPath]!
    var updatedIndexPathsForTracker: [NSIndexPath]!
    
    /* Core Data Convenience */
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    /* Fetched Results Controller for the Tracker */
    lazy var fetchedResultsControllerForTracker: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Artist")
        let nameSort = NSSortDescriptor(key: "artistName", ascending: true)
        fetchRequest.sortDescriptors = [nameSort]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mainCollectionView.backgroundColor = UIColor.clearColor()
        
        var cellNib = UINib(nibName: CollectionViewCellIdentifiers.newReleaseHoldingCollectionCell, bundle: nil)
        mainCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.newReleaseHoldingCollectionCell)
        
        cellNib = UINib(nibName: CollectionViewCellIdentifiers.artistWatchlistCell, bundle: nil)
        mainCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.artistWatchlistCell)
        
        cellNib = UINib(nibName: CollectionViewCellIdentifiers.noNewReleasesCollectionCell, bundle: nil)
        mainCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.noNewReleasesCollectionCell)
        
        cellNib = UINib(nibName: CollectionViewCellIdentifiers.searchingForNewReleasesCollectionCell, bundle: nil)
        mainCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.searchingForNewReleasesCollectionCell)
        
        // set up the flow layout for the collection view cells
        let mainLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        mainLayout.sectionInset = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
        mainLayout.minimumLineSpacing = 8
        mainLayout.scrollDirection = .Vertical
        mainLayout.headerReferenceSize = CGSize(width: self.view.frame.size.width, height: 90)
        
//        let height = 184
//        let width = Int(self.view.bounds.size.width - 16) // -16
//        print(self.view.bounds.size.width)
//        
//        mainLayout.itemSize = CGSize(width: width, height: height)
        mainCollectionView.collectionViewLayout = mainLayout
        
        /* Perform the fetch for the tracker */
        do {
            try fetchedResultsControllerForTracker.performFetch()
        } catch {}
        
        fetchedResultsControllerForTracker.delegate = self
        
        checkForNewReleases()
    }
    
    struct CollectionViewCellIdentifiers {
        static let newReleaseCollectionCell = "NewReleaseCollectionCell"
        static let noNewReleasesCollectionCell = "NoNewReleasesCollectionCell"
        static let newReleaseHoldingCollectionCell = "NewReleaseHoldingCollectionCell"
        static let artistWatchlistCell = "ArtistWatchlistCell"
        static let searchingForNewReleasesCollectionCell = "SearchingForNewReleasesCollectionCell"
    }
    
    func checkForNewReleases() {
        print("Reached checkForNewReleases()")
        
        // perform on main: change the cell to show it is searching...
        
        guard let watchlistArtists = fetchedResultsControllerForTracker.fetchedObjects as? [Artist] else { return }
        print("These are the new releases at launch: \(NewRelease.newReleases)")
        for artist in watchlistArtists {
            artist.delegate = self
            artist.checkForNewRelease()
            
        }
    
    }
    
    func removeArtistFromWatchlist(artist: Artist) {
        
        /* Delete the artist object */
        sharedContext.deleteObject(artist)
        
        /* Save the context */
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func showUrlError(errorMessage: String) {
        presentViewController(alert(errorMessage), animated: true, completion: nil)
    }
    
    func updateNewReleasesCollectionView() {
        
        performOnMain {
            let indexPath = NSIndexPath(forItem: 0, inSection: 0)
            self.mainCollectionView.reloadItemsAtIndexPaths([indexPath])
        }
    }

}


extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if collectionView == mainCollectionView {
            return 2
        } else {
            return 1
        }
    }
    
    func collectionView(collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                                 sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if collectionView == mainCollectionView {
            if indexPath.section == 0 {
                let height = 184
                let width = Int(self.view.bounds.size.width)
                return CGSize(width: width, height: height)
            } else {
                let height = 184
                let width = Int(self.view.bounds.size.width - 16)
                return CGSize(width: width, height: height)
            }
        } else {
            let height = 182
            let width = 128
            return CGSize(width: width, height: height)
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
            print(collectionView)
            if section == 0 {
                return 1
            } else {
                return fetchedResultsControllerForTracker.sections![0].numberOfObjects
            }
        } else {
            return NewRelease.newReleases.count
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if collectionView == mainCollectionView {
            
            if indexPath.section == 0 {
                
                if NewRelease.newReleases.isEmpty {
                    
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
                
                let indexNumber = indexPath.item
                let adjustedIndexPath = NSIndexPath(forItem: indexNumber, inSection: 0)
                
                let artist = fetchedResultsControllerForTracker.objectAtIndexPath(adjustedIndexPath) as! Artist
                
                cell.artist = artist
                cell.artistNameLabel.text = artist.artistName
                cell.genreLabel.text = artist.primaryGenreName
                cell.mostRecentArtwork.image = UIImage(data: (artist.mostRecentArtwork))
                cell.artistId.text = String(format: "Artist Id: %d", artist.artistId)
                cell.delegate = self
                return cell
            }
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCellIdentifiers.newReleaseCollectionCell,
                                                                             forIndexPath: indexPath) as! NewReleaseCollectionCell
            
            let newRelease = NewRelease.newReleases[indexPath.row]
            cell.artistName.text = newRelease.artistName
            cell.newReleaseTitle.text = newRelease.collectionName
            cell.artworkUrl100 = newRelease.artworkUrl100
            cell.newRelease = newRelease
            return cell
        }
        
    }
    
    // MARK: - Fetched Results Controller Delegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        insertedIndexPathsForTracker = [NSIndexPath]()
        deletedIndexPathsForTracker = [NSIndexPath]()
        updatedIndexPathsForTracker = [NSIndexPath]()
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type{
                
        case .Insert:
            print("Insert an item")
            let indexNumber = newIndexPath!.item
            let adjustedIndexPath = NSIndexPath(forItem: indexNumber, inSection: 0)
            insertedIndexPathsForTracker.append(adjustedIndexPath)
            break
        case .Delete:
            print("Delete an item")
            let indexNumber = indexPath!.item
            let adjustedIndexPath = NSIndexPath(forItem: indexNumber, inSection: 0)
            deletedIndexPathsForTracker.append(adjustedIndexPath)
            break
        case .Update:
            print("Update an item.")
            let indexNumber = indexPath!.item
            let adjustedIndexPath = NSIndexPath(forItem: indexNumber, inSection: 0)
            updatedIndexPathsForTracker.append(adjustedIndexPath)
            break
        case .Move:
            print("Move an item. We don't expect to see this in this app.")
            break
        }
            
        
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        
        print("in controllerDidChangeContent. changes.count: \(insertedIndexPathsForTracker.count + deletedIndexPathsForTracker.count)")
        
        mainCollectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPathsForTracker {
                
                let indexNumber = indexPath.item
                let adjustedIndexPath = NSIndexPath(forItem: indexNumber, inSection: 1)
                    
                self.mainCollectionView.insertItemsAtIndexPaths([adjustedIndexPath])
            }
                
            for indexPath in self.deletedIndexPathsForTracker {
                    
                let indexNumber = indexPath.item
                let adjustedIndexPath = NSIndexPath(forItem: indexNumber, inSection: 1)
                
                self.mainCollectionView.deleteItemsAtIndexPaths([adjustedIndexPath])
            }
                
            for indexPath in self.updatedIndexPathsForTracker {
                    
                let indexNumber = indexPath.item
                let adjustedIndexPath = NSIndexPath(forItem: indexNumber, inSection: 1)
                    
                self.mainCollectionView.reloadItemsAtIndexPaths([adjustedIndexPath])
            }
                
            }, completion: nil)
    }

    
    func collectionView(collectionView: UICollectionView,
                        willDisplayCell cell: UICollectionViewCell,
                                        forItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == mainCollectionView {
            
            guard let newReleaseHoldingCollectionCell = cell as? NewReleaseHoldingCollectionCell else { return }
            
            newReleaseHoldingCollectionCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if collectionView != mainCollectionView {
            
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! NewReleaseCollectionCell
            
            if let url = NSURL(string: cell.newRelease!.collectionViewUrl) {
                guard UIApplication.sharedApplication().openURL(url) else {
                    showUrlError("There was an error opening this Artist in iTunes.")
                    return
                }
            } else {
                showUrlError("There was an error opening this Artist in iTunes.")
            }

        }
        
    }

}
