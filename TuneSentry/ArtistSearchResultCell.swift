//
//  ArtistSearchResultCell.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/31/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import Foundation
import UIKit


protocol ArtistSearchResultCellDelegate: class {
    func showUrlError(errorMessage: String)
    func addArtistToWatchlist(searchResult: SearchResult)
    func removeArtistFromWatchlist(searchResult: SearchResult)
}


class ArtistSearchResultCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var addArtistToTracker: UIButton!
    
    var searchResult: SearchResult?

    weak var delegate: ArtistSearchResultCellDelegate?
    
    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGrayColor().CGColor
    
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
        
        if searchResult!.inWatchlist {
            delegate?.removeArtistFromWatchlist(searchResult!)
        } else {
            delegate?.addArtistToWatchlist(searchResult!)
        }
        
    }
    
    
}
