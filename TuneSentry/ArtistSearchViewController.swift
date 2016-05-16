//
//  ArtistSearchViewController.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/15/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import UIKit

class ArtistSearchViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // keyboard should appear upon view loading
        searchBar.becomeFirstResponder()
        
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
        
        
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }

}


// MARK: - Table View Data Source Methods

extension ArtistSearchViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // return a cell depending on what the search state is...
        let cell = UITableViewCell()
        return cell
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
        
        // check the search state... if it hasn't searched yet, is loading, or didn't return any results then return nil
        return nil
        
        // otherwise if there are results, then allow the user to select those results...
    }
    
    
}


