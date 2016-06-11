//
//  ArtistWatchlistCell.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/31/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import Foundation
import UIKit


protocol ArtistWatchlistCellDelegate: class {
    func showUrlError(errorMessage: String)
    func addArtistToWatchlist(searchResult: SearchResult)
    func removeArtistFromWatchlist(searchResult: SearchResult)
}


class ArtistWatchlistCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var mostRecentArtwork: UIImageView!
    @IBOutlet weak var artistId: UILabel!
    
    var artist: Artist?

    weak var delegate: ArtistWatchlistCellDelegate?
    
    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGrayColor().CGColor
    
    }
    
    
    
    // MARK: - Actions
    
    @IBAction func openArtistUrl(sender: UIButton) {
        
        if let url = NSURL(string: artist!.artistLinkUrl) {
            guard UIApplication.sharedApplication().openURL(url) else {
                delegate?.showUrlError("There was an error opening this Artist in iTunes.")
                return
            }
        } else {
            delegate?.showUrlError("There was an error opening this Artist in iTunes.")
        }
    }
    

    @IBAction func removeArtistFromWatchlist(sender: UIButton) {
    }
    
    
}
