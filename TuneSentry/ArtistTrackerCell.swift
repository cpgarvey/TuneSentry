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
    func showUrlError(_ errorMessage: String)
    func removeArtistFromTracker(_ artist: Artist)
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
        layer.borderColor = UIColor.lightGray.cgColor
        layer.cornerRadius = 5
        
    }
    
    
    // MARK: - Actions
    
    @IBAction func openArtistUrl(_ sender: UIButton) {
        
        if let url = URL(string: artist!.artistLinkUrl) {
            guard UIApplication.shared.openURL(url) else {
                delegate?.showUrlError("There was an error opening this Artist in iTunes.")
                return
            }
        } else {
            delegate?.showUrlError("There was an error opening this Artist in iTunes.")
        }
    }
    

    @IBAction func removeArtistFromWatchlist(_ sender: UIButton) {
        // send a message back to the controller that the artist should be removed from the tracker
        delegate?.removeArtistFromTracker(artist!)
    }
    
    
}
