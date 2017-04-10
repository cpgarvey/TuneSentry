//
//  ArtistSearchViewController.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/15/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import UIKit
import CoreData

class ArtistSearchViewController: UIViewController, SearchResultCellDelegate {

    // MARK: - Properties
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var trackerList: [Artist]?
    
    let search = AppleClient()
    
    /* Core Data Convenience */
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // keyboard should appear upon view loading
        searchBar.becomeFirstResponder()
    
        // set the contentInset so that the first rows of the table always fully appears: 44 pts (search bar) 
        collectionView.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)
        
        // load the nibs
        var cellNib = UINib(nibName: CollectionViewCellIdentifiers.searchingCell, bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.searchingCell)
        
        cellNib = UINib(nibName: CollectionViewCellIdentifiers.nothingFoundCell, bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: CollectionViewCellIdentifiers.errorCell, bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.errorCell)
        
        cellNib = UINib(nibName: CollectionViewCellIdentifiers.searchResultCell, bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.searchResultCell)
        
        // set the artists in the tracker
        trackerList = fetchTrackedArtists()
        
        // set up the flow layout for the collection view cells
        let artistSearchResultLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        artistSearchResultLayout.sectionInset = UIEdgeInsets(top: 6, left: 8, bottom: 0, right: 8)
        artistSearchResultLayout.minimumLineSpacing = 6
        artistSearchResultLayout.scrollDirection = .vertical
        
        let height = 100
        let width = Int(self.view.bounds.size.width - 16)
        
        artistSearchResultLayout.itemSize = CGSize(width: width, height: height)
        collectionView.collectionViewLayout = artistSearchResultLayout
        
        // close keyboard if touching anywhere on the screen
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

    }
    
    
    // MARK: - Struct for Collection Cell Identifiers
    
    struct CollectionViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let searchingCell = "SearchingCell"
        static let errorCell = "ErrorCell"
    }
    
    
    // MARK: - SearchResultCellDelegate Methods
    
    func showUrlError(_ errorMessage: String) {
        present(alert(errorMessage), animated: true, completion: nil)
    }
    
    func addArtistToTracker(_ searchResult: SearchResult) {
        
        /* create an Artist object and save it to Core Data */
        let _ = Artist(searchResult: searchResult, context: sharedContext) { success, errorString in
            if success {
                
                performOnMain {
                    /* Save the Core Data Context that includes the new Artist object */
                    CoreDataStackManager.sharedInstance().saveContext()
                
                    /* show HUD indicating to user that Artist was saved */
                    self.showHUD(HudView.TrackerAction.add)
                
                    /* update the watchlist */
                    self.trackerList = self.fetchTrackedArtists()
                    
                    /* reload the table data */
                    self.collectionView.reloadData()
                }
            } else {
                performOnMain {
                    /* update the watchlist */
                    self.trackerList = self.fetchTrackedArtists()

                    /* delete the artist object from Core Data */
                    for artist in self.trackerList! where artist.artistId == searchResult.artistId {
                        self.sharedContext.delete(artist)
                    }
                    /* Save the context */
                    CoreDataStackManager.sharedInstance().saveContext()

                    /* Display error message */
                    self.present(alert(errorString!), animated: true, completion: nil)
                }
            }
        }
    }
    
    func removeArtistFromTracker(_ searchResult: SearchResult) {
        
        /* delete the artist object from Core Data */
        for artist in trackerList! where artist.artistId == searchResult.artistId {
            sharedContext.delete(artist)
        }
        
        /* Save the context */
        CoreDataStackManager.sharedInstance().saveContext()
        
        /* show the user a removal HUD */
        showHUD(HudView.TrackerAction.remove)
        
        /* update the watchlist to reflect current artists after removal of this artist */
        trackerList = fetchTrackedArtists()
        
        /* reload the table data */
        self.collectionView.reloadData()
        
    }
    
    
    // MARK: - Helper Methods
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func fetchTrackedArtists() -> [Artist] {
        let fetchRequest = NSFetchRequest(entityName: "Artist")
        
        do {
            return try sharedContext.fetch(fetchRequest) as! [Artist]
        } catch _ {
            return [Artist]()
        }
    }
    
    func performSearch(_ searchText: String) {
        
        // iTunes API: https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/#searching
        
        search.performSearchForText(searchText, completion: {
            success, error in
            
            if !success {
                let message = "Unable to search at this time"
                self.present(alert(message), animated: true, completion: nil)
            }
            self.collectionView.reloadData()
        })
    }
    
    func showHUD(_ action: HudView.TrackerAction) {
        
        HudView.actionType = action
        
        let hudView = HudView.hudInView(navigationController!.view, animated: true)
        hudView.isUserInteractionEnabled = false
        afterDelay(0.6) {
            hudView.hideAnimated(true)
        }
        hudView.isUserInteractionEnabled = true
    }
}


// MARK: - Search Bar Delegate

extension ArtistSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        performSearch(searchBar.text!)
        // reload the collection view so that the searching cell can be displayed
        collectionView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        performSearch(searchBar.text!)
        // reload the collection view so that the searching cell can be displayed
        collectionView.reloadData()
    }
}


// MARK: - Collection View Data Source Methods

extension ArtistSearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch search.state {
        case .notSearchedYet:
            return 0
        case .searching, .error, .noResults:
            return 1
        case .results(let list):
            // bind the search result array associated with .Results to a temp variable so that you can read how many items are in that associated value
            return list.count
        default:
            fatalError("Should never get here")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch search.state {
            
        // switch is supposed to be exhaustive, so have .NotSearcedYet even though it should never be reached
        case .notSearchedYet:
            
            return UICollectionViewCell()
        case .searching:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellIdentifiers.searchingCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
            
        case .error:
            return collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellIdentifiers.errorCell, for: indexPath)
        
        case .noResults:
            return collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellIdentifiers.nothingFoundCell, for: indexPath)
            
        case .results(let list):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            let searchResult = list[indexPath.row]
            
            // set default inTracker to false to make sure a search result that was formerly in the tracker but removed is now marked false
            searchResult.inTracker = false
            
            // check to see if the search result artist is already in the tracker
            for artist in trackerList! where artist.artistId == searchResult.artistId {
                searchResult.inTracker = true
            }
            
            cell.artistNameLabel.text = searchResult.artistName
            cell.genreLabel.text = searchResult.primaryGenreName
            cell.artistId.text = String(format: "Artist Id: %d", searchResult.artistId)
            
            if searchResult.inTracker {
                cell.addArtistToTracker.setTitle("Remove From Tracker", for: UIControlState())
            } else {
                cell.addArtistToTracker.setTitle("Add Artist To Tracker", for: UIControlState())
            }
            cell.searchResult = searchResult
            cell.delegate = self
            
            return cell

        default:
            fatalError("Should never get here")
        }
        
    }
    
}


// MARK: - Collection View Delegate Method

extension ArtistSearchViewController: UICollectionViewDelegate {
    
    func tableView(_ tableView: UITableView, willSelectRowAtIndexPath indexPath: IndexPath) -> IndexPath? {
        
        searchBar.resignFirstResponder()
        return nil
    }
}


