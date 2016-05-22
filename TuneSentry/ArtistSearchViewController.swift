//
//  ArtistSearchViewController.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/15/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import UIKit

class ArtistSearchViewController: UIViewController, SearchResultCellDelegate {

    // MARK: - Properties
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let search = AppleClient()
    
    
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
        performSearch(searchBar.text!)
    }
    
    func performSearch(searchText: String) {
        
        print(searchText)
        
        // TO DO: add search functionality
        // iTunes API: https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/#searching
        
        search.performSearchForText(searchText, completion: {
            success, error in
            
            if !success {
                // do anything with this?
            }
            self.tableView.reloadData()
        })
        
        tableView.reloadData()
        searchBar.resignFirstResponder()
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
            cell.delegate = self
            cell.artistNameLabel.text = searchResult.artistName
            cell.genreLabel.text = searchResult.genre
            cell.artistUrl = searchResult.artistLinkUrl
            cell.inWatchlist = searchResult.inWatchlist
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


