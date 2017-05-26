//
//  ArtistSearchViewController.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/15/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import UIKit

protocol ArtistSearchViewControllerDelegate {
    func addNewArtists(artistsToAdd: [SearchResult])
    func removeOldArtists(artistsToRemove: [SearchResult])
}

class ArtistSearchViewController: UIViewController, SearchResultCellDelegate {

    // MARK: - Properties
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var searchResults: [SearchResult]?
    
    var currentlyTrackedArtistIds: [Int]? {
        didSet {
            print(currentlyTrackedArtistIds!)
        }
    }
    
    let search = AppleClient()
    
    var isSearching = false
    
    var artistSearchViewControllerDelegate: ArtistSearchViewControllerDelegate?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad called")
        
        configureView()
        
        // close keyboard if touching anywhere on the screen
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !(artistsToAdd.isEmpty) {
            artistSearchViewControllerDelegate?.addNewArtists(artistsToAdd: artistsToAdd)
        }
        
        if !(artistsToRemove.isEmpty) {
            artistSearchViewControllerDelegate?.removeOldArtists(artistsToRemove: artistsToRemove)
        }
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
        
        artistsToAdd?.append(searchResult)
        currentlyTrackedArtistIds?.append(searchResult.artistId)
    }
    
    func removeArtistFromTracker(_ searchResult: SearchResult) {
    
        artistsToRemove?.append(searchResult)
        
        if let index = currentlyTrackedArtistIds?.index(of: searchResult.artistId) {
            currentlyTrackedArtistIds?.remove(at: index)
        }
    }
    
    
    // MARK: - Helper Methods
    
    func configureView() {
        
        // keyboard should appear upon view loading
        searchBar.becomeFirstResponder()
        
        // set the contentInset so that the first rows of the table always fully appears: 44 pts (search bar)
        collectionView.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)
        
        // load the nib
        let cellNib = UINib(nibName: CollectionViewCellIdentifiers.searchResultCell, bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: CollectionViewCellIdentifiers.searchResultCell)
        
        // set up the flow layout for the collection view cells
        let artistSearchResultLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        artistSearchResultLayout.sectionInset = UIEdgeInsets(top: 6, left: 8, bottom: 0, right: 8)
        artistSearchResultLayout.minimumLineSpacing = 6
        artistSearchResultLayout.scrollDirection = .vertical
        
        let height = 100
        let width = Int(self.view.bounds.size.width - 16)
        
        artistSearchResultLayout.itemSize = CGSize(width: width, height: height)
        collectionView.collectionViewLayout = artistSearchResultLayout
        
        activityIndicator.isHidden = true
        
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func performSearch(_ searchText: String) {
        
        // iTunes API: https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/#searching
        
        isSearching = true
        collectionView.reloadData()
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        search.performSearchForText(searchText, completion: {
            success, error, results in
            
            DispatchQueue.main.async {
                self.isSearching = false
                
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                
                if success {
                    self.searchResults = results
                } else {
                    let message = "Unable to search at this time"
                    self.present(alert(message), animated: true, completion: nil)
                }
                
                self.collectionView.reloadData()
            }
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
    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        performSearch(searchBar.text!)
//        // reload the collection view so that the searching cell can be displayed
//        collectionView.reloadData()
//    }
}


// MARK: - Collection View Data Source Methods

extension ArtistSearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if isSearching {
            
            return 0
            
        } else {
            
            guard let searchResults = searchResults else {
                return 0
            }
            
            if searchResults.isEmpty {
                return 0
            } else {
                return searchResults.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let searchResults = searchResults else {
            return UICollectionViewCell()
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
        
        let searchResult = searchResults[indexPath.row]
        
        cell.searchResult = searchResult
        cell.delegate = self
        cell.isBeingTracked = false
        
        currentlyTrackedArtistIds?.forEach { artistId in
            
            if artistId == searchResult.artistId {
                cell.isBeingTracked = true
            }
        }
        
        return cell
    }
}


// MARK: - Collection View Delegate Method

extension ArtistSearchViewController: UICollectionViewDelegate {
    
    func tableView(_ tableView: UITableView, willSelectRowAtIndexPath indexPath: IndexPath) -> IndexPath? {
        
        searchBar.resignFirstResponder()
        return nil
    }
}


