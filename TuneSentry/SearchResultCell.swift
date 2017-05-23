//
//  SearchResultCell.swift
//  TuneSentry
//
//  Created by Chris Garvey on 6/6/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import Foundation
import UIKit

protocol SearchResultCellDelegate: class {
    func showUrlError(_ errorMessage: String)
    func addArtistToTracker(_ searchResult: SearchResult)
    func removeArtistFromTracker(_ searchResult: SearchResult)
    func dismissKeyboard()
}


class SearchResultCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var addArtistToTracker: UIButton!
    @IBOutlet weak var artistId: UILabel!
    
    var searchResult: SearchResult? {
        didSet {
            configureView()
        }
    }
    
    var isBeingTracked = false
    
    weak var delegate: SearchResultCellDelegate?
    
    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
        layer.cornerRadius = 5
        
    }
    
    
    // MARK: - Actions
    
    @IBAction func openArtistUrl(_ sender: UIButton) {
        delegate?.dismissKeyboard()
        if let url = URL(string: searchResult!.artistLinkUrl) {
            
            let options = ["UIApplicationOpenURLOptionUniversalLinksOnly" : 0]
            
            UIApplication.shared.open(url, options: options, completionHandler: { success in
                
                if !success {
                    
                    self.delegate?.showUrlError("There was an error opening this Artist in iTunes.")
                    return
                    
                }
            })
        } else {
            delegate?.showUrlError("There was an error opening this Artist in iTunes.")
        }
    }
    
    
    @IBAction func addArtistToWatchlist(_ sender: UIButton) {
        delegate?.dismissKeyboard()
        
        isBeingTracked ? delegate?.removeArtistFromTracker(searchResult!) : delegate?.addArtistToTracker(searchResult!)
        
    }
    
    // MARK: Helper Function
    
    func configureView() {
        
        guard let searchResult = searchResult else {
            return
        }
        
        artistNameLabel.text = searchResult.artistName
        genreLabel.text = searchResult.primaryGenreName
        artistId.text = String(format: "Artist Id: %d", searchResult.artistId)
        
        DispatchQueue.main.async {
            self.setTrackedStatus(searchResult: searchResult)
        }
        
        
    }
    
    func setTrackedStatus(searchResult: SearchResult) {
        
        // check to see if the search result artist is already in the tracker
        for artist in Artist.trackedArtists! where artist.artistId == searchResult.artistId {
            isBeingTracked = true
        }
        
        isBeingTracked ? addArtistToTracker.setTitle("Remove From Tracker", for: UIControlState()) : addArtistToTracker.setTitle("Add Artist To Tracker", for: UIControlState())

    }
    
}
