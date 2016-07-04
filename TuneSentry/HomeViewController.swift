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
    
    struct CollectionViewCellIdentifiers {
        static let newReleaseCollectionCell = "NewReleaseCollectionCell"
        static let noNewReleasesCollectionCell = "NoNewReleasesCollectionCell"
        static let newReleaseHoldingCollectionCell = "NewReleaseHoldingCollectionCell"
        static let artistTrackerCell = "ArtistTrackerCell"
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mainCollectionView.backgroundColor = UIColor.clearColor()
        
        var cellNib = UINib(nibName: CollectionViewCellIdentifiers.newReleaseHoldingCollectionCell, bundle: nil)
        mainCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.newReleaseHoldingCollectionCell)
        
        cellNib = UINib(nibName: CollectionViewCellIdentifiers.artistTrackerCell, bundle: nil)
        mainCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.artistTrackerCell)
        
        cellNib = UINib(nibName: CollectionViewCellIdentifiers.noNewReleasesCollectionCell, bundle: nil)
        mainCollectionView.registerNib(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.noNewReleasesCollectionCell)
        
        // set up the flow layout for the collection view cells
        let mainLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        mainLayout.sectionInset = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
        mainLayout.minimumLineSpacing = 8
        mainLayout.scrollDirection = .Vertical
        mainLayout.headerReferenceSize = CGSize(width: self.view.frame.size.width, height: 90)
        mainCollectionView.collectionViewLayout = mainLayout
        
        /* Perform the fetch for the tracker */
        do {
            try fetchedResultsControllerForTracker.performFetch()
        } catch {}
        
        fetchedResultsControllerForTracker.delegate = self
        
        /* Check for new releases from the artists currently in the tracker */
        checkForNewReleases()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // reload the main collection view so that new artists can be displayed after being added from the search
        mainCollectionView.reloadData()
    }
    
    
    // MARK: - Helper Functions
    
    func checkForNewReleases() {
        
        guard let watchlistArtists = fetchedResultsControllerForTracker.fetchedObjects as? [Artist] else { return }
        
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
            self.mainCollectionView.reloadData()
        }
    }

}


extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if collectionView == mainCollectionView {
            return 2
        } else {
            // if the collection view is in the NewReleasesHoldingCollectionCell, we just want one section
            return 1
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if collectionView == mainCollectionView {
            if indexPath.section == 0 {
                // if it is section 0 of the main collection view, then the collection cell should stretch from edge to edge with no margins
                let height = 184
                let width = Int(self.view.bounds.size.width)
                return CGSize(width: width, height: height)
            } else {
                // if it is section 1 of the main collection view, then the collection cells need appropriate right and left margins
                let height = 184
                let width = Int(self.view.bounds.size.width - 16)
                return CGSize(width: width, height: height)
            }
        } else {
            // if the collection view is in the NewReleasesHoldingCollectionCell, then we set the layout for the new releases
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
                    if NewRelease.newReleases.isEmpty {
                        headerView.header.text = "No New Releases"
                    } else {
                        headerView.header.text = "New Releases:"
                    }
                } else {
                    let numberOfArtists = fetchedResultsControllerForTracker.sections![0].numberOfObjects
                    if numberOfArtists == 0 {
                        headerView.header.text = "No Tracked Artists"
                    } else {
                        headerView.header.text = "Artist Tracker:"
                    }
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
                // the first section of the main collection view will always be just one item
                return 1
            } else {
                // the second section of main collection view will display artists
                return fetchedResultsControllerForTracker.sections![0].numberOfObjects
            }
        } else {
            // the collection view in the NewReleasesHoldingCollectionCell will display the new releases (if any)
            return NewRelease.newReleases.count
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if collectionView == mainCollectionView {
            
            if indexPath.section == 0 {
                
                if NewRelease.newReleases.isEmpty {
                    
                    // if there are no new releases, just display a blank spacer cell
                    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCellIdentifiers.noNewReleasesCollectionCell,
                                                                                     forIndexPath: indexPath)
                    
                    return cell
                } else {
                    
                    // if there are new releases, then display the holding cell that contains a collection view to display the new releases
                    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCellIdentifiers.newReleaseHoldingCollectionCell,
                                                                                     forIndexPath: indexPath)
                    return cell
                }
                
            } else {
                // in the section section of the main collection view, return the artist cells  
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCellIdentifiers.artistTrackerCell, forIndexPath: indexPath) as! ArtistTrackerCell
                
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
            // if the collection view is the one in the NewReleaseHoldingCollectionCell, then return the new release cells
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
        
            // we need to adjust the index paths to match the core data section paths, which are "0" -- in the collection view the paths are in section "1"
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
            
            // as above, need to adjust the index path sections to put them into the correct section in the collection view
            
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
            // set the data source delegate of the collection view in the NewReleaseHoldingCollectionCell to this file
            newReleaseHoldingCollectionCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if collectionView != mainCollectionView {
            // if the collection view is in the NewReleaseHoldingCollectionCell, then selecting a cell should take you to the new release in iTunes
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
