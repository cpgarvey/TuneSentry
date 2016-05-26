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
    @IBOutlet weak var tableView: UITableView!
    
    var watchlist: [Artist]?
    
    let search = AppleClient()
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // keyboard should appear upon view loading
        searchBar.becomeFirstResponder()
    
        // set the contentInset so that the first rows of the table always fully appears: 44 pts (search bar) 
        tableView.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)
        
        // load the nibs
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchingCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchingCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.errorCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.errorCell)
        
        // adjust the row height of the table to accomodate our custom nibs
        tableView.rowHeight = 80
        
        // set the artist watchlist
        watchlist = fetchWatchlistArtists()
        
    }
    
    
    // MARK: - Struct for Cell Identifiers
    
    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let searchingCell = "SearchingCell"
        static let errorCell = "ErrorCell"
    }
    
    
    // MARK: - SearchResultCell Delegate Methods
    
    func showUrlError(errorMessage: String) {
        presentViewController(alert(errorMessage), animated: true, completion: nil)
    }
    
    func addArtistToWatchlist(searchResult: SearchResult) {
        
        /* create an Artist object and save it to Core Data */
        let _ = Artist(searchResult: searchResult, context: sharedContext) { success in
            if success {
                
                performOnMain {
                    /* Save the Core Data Context that includes the new Artist object */
                    CoreDataStackManager.sharedInstance().saveContext()
                
                    /* show HUD indicating to user that Artist was saved */
                    self.showHUD(HudView.WatchlistAction.Add)
                
                    /* update the watchlist */
                    self.watchlist = self.fetchWatchlistArtists()
                    print(self.watchlist)
                    
                    /* reload the table data */
                    self.tableView.reloadData()
                }
            } else {
                // print an error message
            }
            
        }
        
    }
    
    func removeArtistFromWatchlist(searchResult: SearchResult) {
        
        /* delete the artist object from Core Data */
        for artist in watchlist! where artist.artistId == searchResult.artistId {
            sharedContext.deleteObject(artist)
        }
        
        /* Save the context */
        CoreDataStackManager.sharedInstance().saveContext()
        
        /* show the user a removal HUD */
        showHUD(HudView.WatchlistAction.Remove)
        
        /* update the watchlist to reflect current artists after removal of this artist */
        watchlist = fetchWatchlistArtists()
        
        /* reload the table data */
        self.tableView.reloadData()
        
    }
    
    
    // MARK: - Helper Methods
    
    func fetchWatchlistArtists() -> [Artist] {
        let fetchRequest = NSFetchRequest(entityName: "Artist")
        
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [Artist]
        } catch _ {
            return [Artist]()
        }
    }
    
    func performSearch(searchText: String) {
        
        print(searchText)
        
        // iTunes API: https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/#searching
        
        search.performSearchForText(searchText, completion: {
            success, error in
            
            if !success {
                // do anything with this?
            }
            self.tableView.reloadData()
        })
    }
    
    func showHUD(action: HudView.WatchlistAction) {
        
        HudView.actionType = action
        
        let hudView = HudView.hudInView(navigationController!.view, animated: true)
        hudView.userInteractionEnabled = false
        afterDelay(0.6) {
            hudView.hideAnimated(true)
        }
        hudView.userInteractionEnabled = true
    }

}


// MARK: - Search Bar Delegate

extension ArtistSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        performSearch(searchBar.text!)
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        performSearch(searchBar.text!)
    }

}


// MARK: - Table View Data Source Methods

extension ArtistSearchViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch search.state {
        case .NotSearchedYet:
            return 0
        case .Searching, .Error, .NoResults:
            return 1
        case .Results(let list):
            // bind the search result array associated with .Results to a temp variable so that you can read how many items are in that associated value
            return list.count
        }
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch search.state {
            
        // switch is supposed to be exhaustive, so have .NotSearcedYet even though it should never be reached
        case .NotSearchedYet:
            fatalError("Should never get here")
            
        case .Searching:
            print("reached")
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchingCell, forIndexPath: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
            
        case .Error:
            return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.errorCell, forIndexPath: indexPath)
        
        case .NoResults:
            return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath)
            
        case .Results(let list):
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
            let searchResult = list[indexPath.row]
            
            // set default inWatchlist to false to make sure a search result that was formerly in the watchlist but removed is now marked false
            searchResult.inWatchlist = false
            
            // check to see if the search result artist is already in the watchlist
            for artist in watchlist! where artist.artistId == searchResult.artistId {
                searchResult.inWatchlist = true
            }
            
            cell.artistNameLabel.text = searchResult.artistName
            cell.genreLabel.text = searchResult.primaryGenreName
            
            if searchResult.inWatchlist {
                cell.addArtistToTracker.setTitle("Remove From Tracker", forState: .Normal)
            } else {
                cell.addArtistToTracker.setTitle("Add Artist To Tracker", forState: .Normal)
            }
            cell.searchResult = searchResult
            cell.delegate = self
            
            return cell

        }
        
    }
    
}


// MARK: - Table View Delegate Methods

extension ArtistSearchViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        searchBar.resignFirstResponder()
        
        // TO DO: add the artist in that row to the artist watch list
        // TO DO: use HUD to indicate to user the artist was successfully added
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        switch search.state {
        case .NotSearchedYet, .Error, .Searching, .NoResults:
            return nil
        case .Results: //you don't need to bind the array here because you're not using it for anything
            return indexPath
        }
    }
    
    
}


