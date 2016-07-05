//
//  ArtistWatchlistCell.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/31/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import Foundation
import UIKit


protocol ArtistTrackerCellDelegate: class {
    func showUrlError(errorMessage: String)
    func removeArtistFromTracker(artist: Artist)
}


class ArtistTrackerCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var mostRecentArtwork: UIImageView!
    @IBOutlet weak var artistId: UILabel!
    @IBOutlet weak var bottomView: UIView!
    
    var artist: Artist?

    weak var delegate: ArtistTrackerCellDelegate?
    
    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGrayColor().CGColor
        layer.cornerRadius = 5
        
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
        // send a message back to the controller that the artist should be removed from the tracker
        delegate?.removeArtistFromTracker(artist!)
    }
    
    
}
