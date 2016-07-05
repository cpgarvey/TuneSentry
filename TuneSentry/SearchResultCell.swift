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
    func showUrlError(errorMessage: String)
    func addArtistToTracker(searchResult: SearchResult)
    func removeArtistFromTracker(searchResult: SearchResult)
}


class SearchResultCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var addArtistToTracker: UIButton!
    @IBOutlet weak var artistId: UILabel!
    
    var searchResult: SearchResult?
    
    weak var delegate: SearchResultCellDelegate?
    
    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGrayColor().CGColor
        layer.cornerRadius = 5
        
    }
    
    
    // MARK: - Actions
    
    @IBAction func openArtistUrl(sender: UIButton) {
        
        if let url = NSURL(string: searchResult!.artistLinkUrl) {
            guard UIApplication.sharedApplication().openURL(url) else {
                delegate?.showUrlError("There was an error opening this Artist in iTunes.")
                return
            }
        } else {
            delegate?.showUrlError("There was an error opening this Artist in iTunes.")
        }
    }
    
    
    @IBAction func addArtistToWatchlist(sender: UIButton) {
        
        if searchResult!.inTracker {
            // if the artist is already being tracked, then send a message to the delegate removing the artist
            delegate?.removeArtistFromTracker(searchResult!)
        } else {
            // otherwise tell the delegat to add the artist to the tracker
            delegate?.addArtistToTracker(searchResult!)
        }
        
    }
    
}
