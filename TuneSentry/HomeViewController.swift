//
//  HomeViewController.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/28/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController, ArtistTrackerCellDelegate, ArtistDelegate, NewReleaseCollectionViewDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    let search = AppleClient()
    
    @IBOutlet weak var searchHorizontalBarConstraint: NSLayoutConstraint!
    @IBOutlet weak var checkingView: UIView!
    @IBOutlet weak var noResultsFoundView: UIView!
    
    /* Variable properties to keep track of insertions, deletions, and updates */
    var insertedIndexPathsForTracker: [IndexPath]!
    var deletedIndexPathsForTracker: [IndexPath]!
    var updatedIndexPathsForTracker: [IndexPath]!
    
    var coreDataStack: CoreDataStack!
    var fetchedResultsController: NSFetchedResultsController<Artist> = NSFetchedResultsController()
    
    var newlyOpened = true
    
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
        
        configureView()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        // reload the main collection view so that new artists can be displayed after being added from the search
//        mainCollectionView.reloadSections(IndexSet(integer: 1))
//    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if newlyOpened {
            
            newlyOpened = !newlyOpened
            
            if !(fetchedResultsController.fetchedObjects?.isEmpty)! {
                
                /* Check for new releases from the artists currently in the tracker */
                checkForNewReleases()
            }
        } else {
            newlyOpened = !newlyOpened
        }
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchSegue" {
            
            let currentlyTrackedArtists = Artist.trackedArtists
            
            var currentlyTrackedArtistIds = [Int]()
            
            currentlyTrackedArtists?.forEach { artist in
                
                currentlyTrackedArtistIds.append(artist.artistId)
            }
            
            let artistSearchViewController = segue.destination as! ArtistSearchViewController
            
            artistSearchViewController.currentlyTrackedArtistIds = currentlyTrackedArtistIds
            
            artistSearchViewController.artistSearchViewControllerDelegate = self
        }
    }
    
    
    // MARK: - Helper Functions
    
    func configureView() {
        
        fetchedResultsController = fetchedResultsControllerForTracker()
        
        mainCollectionView.backgroundColor = UIColor.clear
        checkingView.isHidden = true
        noResultsFoundView.isHidden = true
        
        let  cellNib = UINib(nibName: CollectionViewCellIdentifiers.artistTrackerCell, bundle: nil)
        mainCollectionView.register(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.artistTrackerCell)
        
        // set up the flow layout for the collection view cells
        let mainLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        mainLayout.sectionInset = UIEdgeInsets(top: 6, left: 0, bottom: 8, right: 0)
        mainLayout.minimumLineSpacing = 8
        mainLayout.scrollDirection = .vertical
        mainCollectionView.collectionViewLayout = mainLayout

        /* Perform the fetch for the tracker */
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        fetchedResultsController.delegate = self
        
        Artist.trackedArtists = fetchTrackedArtists()
        
    }
    
    func openSearchSpace() {
        
        searchHorizontalBarConstraint.constant = 0
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 1.0, delay: 1.0, usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 10.0, options: .curveEaseIn,
                       animations: {
                        self.searchHorizontalBarConstraint.constant = 58
                        self.view.layoutIfNeeded()
        },
                       completion: nil
        )
    }
    
    func closeSearchSpace() {
        
        searchHorizontalBarConstraint.constant = 58
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 10.0, options: .curveEaseIn,
                       animations: {
                        self.searchHorizontalBarConstraint.constant = 0
                        self.view.layoutIfNeeded()
        },
                       completion: nil
        )
        
    }
    
    func openSpaceForNewReleases() {
        
        searchHorizontalBarConstraint.constant = 58
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 10.0, options: .curveEaseIn,
                       animations: {
                        self.searchHorizontalBarConstraint.constant = 198
                        self.view.layoutIfNeeded()
        },
                       completion: nil
        )

        
    }
    
    
    func fetchedResultsControllerForTracker() -> NSFetchedResultsController<Artist> {
        let fetchedResultController = NSFetchedResultsController(fetchRequest: artistFetchRequest(),
                                                                 managedObjectContext: coreDataStack.mainContext,
                                                                 sectionNameKeyPath: nil,
                                                                 cacheName: nil)
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
        } catch let error as NSError {
            fatalError("Error: \(error.localizedDescription)")
        }
        
        return fetchedResultController
    }
    
    func artistFetchRequest() -> NSFetchRequest<Artist> {
        let fetchRequest = NSFetchRequest<Artist>(entityName: "Artist")
        fetchRequest.fetchBatchSize = 20
        
        let sortDescriptor = NSSortDescriptor(key: "artistName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        return fetchRequest
    }
    
    func checkForNewReleases() {
        
        checkingView.isHidden = false
        openSearchSpace()
        
        guard let trackedArtists = fetchedResultsController.fetchedObjects else { return }
        
        NewRelease.checkingForNewReleases = true
        NewRelease.artistsToCheck = trackedArtists.count
        
        for artist in trackedArtists {
            artist.delegate = self
            artist.checkForNewRelease()
        }
    }
    
    func removeArtistFromTracker(_ artist: Artist) {
        
        /* Delete the artist object */
        coreDataStack.mainContext.delete(artist)
        
        /* Save the context */
        coreDataStack.saveContext() { success in
            
            if success {
                
                if fetchedResultsController.sections![0].numberOfObjects == 0 {
                    self.mainCollectionView.reloadSections(IndexSet(integer: 0))
                }
                
            } else {
                print("Error: couldn't save context")
            }
            
        }
    }
    
    func showUrlError(_ errorMessage: String) {
        present(alert(errorMessage), animated: true, completion: nil)
    }
    
    func updateNewReleasesView() {
        
        NewRelease.checkingForNewReleases = false
        
        if NewRelease.newReleases.isEmpty {
            
            DispatchQueue.main.async {
                self.checkingView.isHidden = true
                self.noResultsFoundView.isHidden = false
            }
            
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when, execute: {
                self.closeSearchSpace()
                self.noResultsFoundView.isHidden = true
            })
            
        } else {
            
            // set up the flow layout for the collection view cells
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
            layout.minimumLineSpacing = 8
            layout.scrollDirection = .horizontal
            
            let collectionViewWidth: CGFloat = view.frame.size.width
            let collectionViewHeight: CGFloat = 198
            
            let collectionViewRect = CGRect(
                x: 0,
                y: 65,
                width: collectionViewWidth,
                height: collectionViewHeight)
            
            let newReleaseCollectionView = NewReleaseCollectionView(frame: collectionViewRect, collectionViewLayout: layout)
            
            newReleaseCollectionView.newReleaseCollectionViewDelegate = self
            
            DispatchQueue.main.async {
                self.checkingView.isHidden = true
                self.openSpaceForNewReleases()
                self.view.addSubview(newReleaseCollectionView)
            }
        }
    }
    
    func fetchTrackedArtists() -> [Artist] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Artist")
        
        do {
            return try coreDataStack.mainContext.fetch(fetchRequest) as! [Artist]
        } catch _ {
            return [Artist]()
        }
    }

}


extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let height = 154
        let width = Int(self.view.bounds.size.width - 16)
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return fetchedResultsController.sections![0].numberOfObjects
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellIdentifiers.artistTrackerCell, for: indexPath) as! ArtistTrackerCell
        
        let indexNumber = indexPath.item
        let adjustedIndexPath = IndexPath(item: indexNumber, section: 0)
        
        let artist = fetchedResultsController.object(at: adjustedIndexPath)
        
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
            insertedIndexPathsForTracker.append(newIndexPath!)
            break
        case .delete:
            deletedIndexPathsForTracker.append(indexPath!)
            break
        case .update:
            updatedIndexPathsForTracker.append(indexPath!)
            break
        case .move:
            print("Move an item. We don't expect to see this in this app.")
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        mainCollectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPathsForTracker {
                self.mainCollectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.deletedIndexPathsForTracker {
                self.mainCollectionView.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.updatedIndexPathsForTracker {
                self.mainCollectionView.reloadItems(at: [indexPath])
            }
            
            }, completion: nil)
    }
}


// MARK: - ArtistSearchViewControllerDelegate

extension HomeViewController: ArtistSearchViewControllerDelegate {
    
    func addNewArtists(artistsToAdd: [SearchResult]) {
        
        artistsToAdd.forEach { searchResult in
         
            addArtistToTracker(searchResult)
        }
    }
    
    func removeOldArtists(artistsToRemove: [SearchResult]) {
        
        artistsToRemove.forEach { searchResult in
            
            removeArtistFromTracker(searchResult)
        }
    }
    
    func addArtistToTracker(_ searchResult: SearchResult) {
        
        /* create an Artist object and save it to Core Data */
        let artist = Artist(context: coreDataStack.mainContext)
        artist.populateArtistFieldsWith(searchResult: searchResult, completion: { success, errorString in
            
            if success {
                
                /* Save the Core Data Context that includes the new Artist object */
                self.coreDataStack.saveContext() { success in
                    
                    if success {
                        
                        Artist.trackedArtists = self.fetchTrackedArtists()
                        
                    } else {
                        
                        print("Core Data save failed")
                        
                    }
                }
                
            } else {
                
                /* update the watchlist */
                Artist.trackedArtists = self.fetchTrackedArtists()
                
                /* delete the artist object from Core Data */
                for artist in Artist.trackedArtists! where artist.artistId == searchResult.artistId {
                    self.coreDataStack.mainContext.delete(artist)
                }
                
                /* Save the context */
                self.coreDataStack.saveContext() { success in
                    
                    if success {
                        
                        /* Display error message */
                        self.present(alert(errorString!), animated: true, completion: nil)
                        
                    } else {
                        
                        print("Core Data save failed")
                        
                    }
                }
            }
        })
    }

    func removeArtistFromTracker(_ searchResult: SearchResult) {
        
        /* delete the artist object from Core Data */
        for artist in Artist.trackedArtists! where artist.artistId == searchResult.artistId {
            coreDataStack.mainContext.delete(artist)
        }
        
        /* Save the context */
        coreDataStack.saveContext() { success in
            
            if success {
                
                /* update the watchlist to reflect current artists after removal of this artist */
                Artist.trackedArtists = fetchTrackedArtists()
                
            } else {
                
                print("Unable to save context")
                
            }
        }
    }
}
