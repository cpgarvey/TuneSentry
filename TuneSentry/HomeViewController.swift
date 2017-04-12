//
//  HomeViewController.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/28/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController, ArtistTrackerCellDelegate, ArtistDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    let search = AppleClient()
    
    /* Variable properties to keep track of insertions, deletions, and updates */
    var insertedIndexPathsForTracker: [IndexPath]!
    var deletedIndexPathsForTracker: [IndexPath]!
    var updatedIndexPathsForTracker: [IndexPath]!
    
    /* Core Data Properties */
    var coreDataStack: CoreDataStack!
    
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
        static let searchingCell = "SearchingCell"
        static let newReleasesCollectionSpacerCell = "NewReleasesCollectionSpacerCell"
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mainCollectionView.backgroundColor = UIColor.clear
        
        var cellNib = UINib(nibName: CollectionViewCellIdentifiers.newReleaseHoldingCollectionCell, bundle: nil)
        mainCollectionView.register(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.newReleaseHoldingCollectionCell)
        
        cellNib = UINib(nibName: CollectionViewCellIdentifiers.artistTrackerCell, bundle: nil)
        mainCollectionView.register(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.artistTrackerCell)
        
        cellNib = UINib(nibName: CollectionViewCellIdentifiers.noNewReleasesCollectionCell, bundle: nil)
        mainCollectionView.register(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.noNewReleasesCollectionCell)
        
        cellNib = UINib(nibName: CollectionViewCellIdentifiers.searchingCell, bundle: nil)
        mainCollectionView.register(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.searchingCell)
        
        cellNib = UINib(nibName: CollectionViewCellIdentifiers.newReleasesCollectionSpacerCell, bundle: nil)
        mainCollectionView.register(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.newReleasesCollectionSpacerCell)
        
        // set up the flow layout for the collection view cells
        let mainLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        mainLayout.sectionInset = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
        mainLayout.minimumLineSpacing = 8
        mainLayout.scrollDirection = .vertical
        mainLayout.headerReferenceSize = CGSize(width: self.view.frame.size.width, height: 90)
        mainCollectionView.collectionViewLayout = mainLayout
        
        /* Perform the fetch for the tracker */
        do {
            try fetchedResultsControllerForTracker.performFetch()
        } catch {}
        
        fetchedResultsControllerForTracker.delegate = self
        if !(fetchedResultsControllerForTracker.fetchedObjects?.isEmpty)! {
        
            /* Check for new releases from the artists currently in the tracker */
            checkForNewReleases()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // reload the main collection view so that new artists can be displayed after being added from the search
        mainCollectionView.reloadSections(IndexSet(integer: 1))
    }
    
    
    // MARK: - Helper Functions
    
    func checkForNewReleases() {
        guard let trackedArtists = fetchedResultsControllerForTracker.fetchedObjects as? [Artist] else { return }
        
        NewRelease.checkingForNewReleases = true
        mainCollectionView.reloadSections(IndexSet(integer: 0))
        NewRelease.artistsToCheck = trackedArtists.count
        print("Artists to check: \(NewRelease.artistsToCheck)")
        
        for artist in trackedArtists {
            artist.delegate = self
            artist.checkForNewRelease()
            
        }
    
    }
    
    func removeArtistFromTracker(_ artist: Artist) {
        
        /* Delete the artist object */
        sharedContext.delete(artist)
        
        /* Save the context */
        CoreDataStackManager.sharedInstance().saveContext()
        
        if fetchedResultsControllerForTracker.sections![0].numberOfObjects == 0 {
            mainCollectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    
    func showUrlError(_ errorMessage: String) {
        present(alert(errorMessage), animated: true, completion: nil)
    }
    
    func updateNewReleasesCollectionView() {
        
        performOnMain {
            NewRelease.checkingForNewReleases = false
            self.mainCollectionView.reloadData()
        }
    }

}


extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == mainCollectionView {
            return 2
        } else {
            // if the collection view is in the NewReleasesHoldingCollectionCell, we just want one section
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if collectionView == mainCollectionView {
            
            switch kind {
                
            case UICollectionElementKindSectionHeader:
                
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HomeHeaderView", for: indexPath) as! HomeHeaderView
                
                if indexPath.section == 0 {
                    headerView.header.text = "New Releases:"
                    
                } else {
                    headerView.header.text = "Artist Tracker:"
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

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == mainCollectionView {
            
            if indexPath.section == 0 {
                
                if NewRelease.checkingForNewReleases {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellIdentifiers.searchingCell,
                                                                                     for: indexPath)
                    let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
                    spinner.startAnimating()
                    return cell
                } else if NewRelease.newReleases.isEmpty && fetchedResultsControllerForTracker.sections![0].numberOfObjects > 0 {
                    
                    // if there are no new releases, just display a blank spacer cell
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellIdentifiers.noNewReleasesCollectionCell,
                                                                                     for: indexPath)
                    
                    return cell
                } else if fetchedResultsControllerForTracker.sections![0].numberOfObjects == 0 {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellIdentifiers.newReleasesCollectionSpacerCell,
                                                                                     for: indexPath)
                    
                    return cell
                    
                } else {
                    // if there are new releases, then display the holding cell that contains a collection view to display the new releases
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellIdentifiers.newReleaseHoldingCollectionCell,
                                                                                     for: indexPath)
                    return cell
                }
                
            } else {
                
                // in the section section of the main collection view, return the artist cells
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellIdentifiers.artistTrackerCell, for: indexPath) as! ArtistTrackerCell
                
                let indexNumber = indexPath.item
                let adjustedIndexPath = IndexPath(item: indexNumber, section: 0)
                
                let artist = fetchedResultsControllerForTracker.object(at: adjustedIndexPath) as! Artist
                
                cell.artist = artist
                cell.artistNameLabel.text = artist.artistName
                cell.genreLabel.text = artist.primaryGenreName
                cell.artistId.text = String(format: "Artist Id: %d", artist.artistId)
                cell.delegate = self
                
                if artist.mostRecentArtwork != nil {
                    cell.mostRecentArtwork.image = UIImage(data: (artist.mostRecentArtwork!))
                } else {
                    /* Citation for placeholder image */
                    // license link: https://creativecommons.org/licenses/by/3.0/
                    // attribution: https://www.iconfinder.com/icons/1105258/brand_circle_music_note_shape_icon#size=128
                    cell.mostRecentArtwork.image = UIImage(named: "placeholder")
                }
                
                return cell
                
            }
        } else {
            // if the collection view is the one in the NewReleaseHoldingCollectionCell, then return the new release cells
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellIdentifiers.newReleaseCollectionCell,
                                                                             for: indexPath) as! NewReleaseCollectionCell
            
            let newRelease = NewRelease.newReleases[indexPath.row]
            cell.artistName.text = newRelease.artistName
            cell.newReleaseTitle.text = newRelease.collectionName
            cell.artworkUrl100 = newRelease.artworkUrl100
            cell.newRelease = newRelease
            return cell
        }
        
    }
    
    
    // MARK: - Fetched Results Controller Delegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        insertedIndexPathsForTracker = [IndexPath]()
        deletedIndexPathsForTracker = [IndexPath]()
        updatedIndexPathsForTracker = [IndexPath]()
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type{
        
            // we need to adjust the index paths to match the core data section paths, which are "0" -- in the collection view the paths are in section "1"
        case .insert:
            print("Insert an item")
            let indexNumber = newIndexPath!.item
            let adjustedIndexPath = IndexPath(item: indexNumber, section: 0)
            insertedIndexPathsForTracker.append(adjustedIndexPath)
            break
        case .delete:
            print("Delete an item")
            let indexNumber = indexPath!.item
            let adjustedIndexPath = IndexPath(item: indexNumber, section: 0)
            deletedIndexPathsForTracker.append(adjustedIndexPath)
            break
        case .update:
            print("Update an item.")
            let indexNumber = indexPath!.item
            let adjustedIndexPath = IndexPath(item: indexNumber, section: 0)
            updatedIndexPathsForTracker.append(adjustedIndexPath)
            break
        case .move:
            print("Move an item. We don't expect to see this in this app.")
            break
        }
            
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        
        print("in controllerDidChangeContent. changes.count: \(insertedIndexPathsForTracker.count + deletedIndexPathsForTracker.count)")
        
        mainCollectionView.performBatchUpdates({() -> Void in
            
            // as above, need to adjust the index path sections to put them into the correct section in the collection view
            
            for indexPath in self.insertedIndexPathsForTracker {
                
                let indexNumber = indexPath.item
                let adjustedIndexPath = IndexPath(item: indexNumber, section: 1)
                    
                self.mainCollectionView.insertItems(at: [adjustedIndexPath])
            }
                
            for indexPath in self.deletedIndexPathsForTracker {
                    
                let indexNumber = indexPath.item
                let adjustedIndexPath = IndexPath(item: indexNumber, section: 1)
                
                self.mainCollectionView.deleteItems(at: [adjustedIndexPath])
            }
                
            for indexPath in self.updatedIndexPathsForTracker {
                    
                let indexNumber = indexPath.item
                let adjustedIndexPath = IndexPath(item: indexNumber, section: 1)
                    
                self.mainCollectionView.reloadItems(at: [adjustedIndexPath])
            }
                
            }, completion: nil)
    }

    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                                        forItemAt indexPath: IndexPath) {
        if collectionView == mainCollectionView {
            
            guard let newReleaseHoldingCollectionCell = cell as? NewReleaseHoldingCollectionCell else { return }
            // set the data source delegate of the collection view in the NewReleaseHoldingCollectionCell to this file
            newReleaseHoldingCollectionCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView != mainCollectionView {
            // if the collection view is in the NewReleaseHoldingCollectionCell, then selecting a cell should take you to the new release in iTunes
            let cell = collectionView.cellForItem(at: indexPath) as! NewReleaseCollectionCell
            
            if let url = URL(string: cell.newRelease!.collectionViewUrl) {
                guard UIApplication.shared.openURL(url) else {
                    showUrlError("There was an error opening this Artist in iTunes.")
                    return
                }
            } else {
                showUrlError("There was an error opening this Artist in iTunes.")
            }

        }
    }

}
