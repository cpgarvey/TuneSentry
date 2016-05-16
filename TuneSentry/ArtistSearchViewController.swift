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
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // keyboard should appear upon view loading
        searchBar.becomeFirstResponder()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}



extension ArtistSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        performSearch(searchBar.text!)
    }
    
    func performSearch(searchText: String) {
        
        print(searchText)
        // TO DO: add search functionality
        
        searchBar.resignFirstResponder()
    }

}


