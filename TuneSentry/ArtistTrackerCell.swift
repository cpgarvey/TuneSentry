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
    @IBOutlet weak var removeArtistFromWatchlistButton: UIButton!
    
    var artist: Artist? {
        didSet {
            configureViewFor(button: removeArtistFromWatchlistButton)
        }
    }

    weak var delegate: ArtistTrackerCellDelegate?
    
    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        self.layer.shadowRadius = 2
        self.layer.masksToBounds = false
        self.clipsToBounds = false
        self.layer.cornerRadius = 5
        
    }
    
    
    // MARK: - Actions
    
    @IBAction func openArtistUrl(_ sender: UIButton) {
        
        if let url = URL(string: artist!.artistLinkUrl) {
            
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
    
    @IBAction func removeArtistFromWatchlistTouchDown(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.05, delay: 0.0, options: [], animations: {
            self.removeArtistFromWatchlistButton.center.y += 2.0
            self.removeArtistFromWatchlistButton.layer.shadowOpacity = 0.0
        }, completion: nil)
    }

    @IBAction func removeArtistFromWatchlist(_ sender: UIButton) {
        
        // return button to original position
        UIView.animate(withDuration: 0.05, delay: 0.0, options: [], animations: {
            self.removeArtistFromWatchlistButton.center.y -= 2.0
            self.removeArtistFromWatchlistButton.layer.shadowOpacity = 0.5
        }, completion: nil)
        
        // send a message back to the controller that the artist should be removed from the tracker
        delegate?.removeArtistFromTracker(artist!)
    }
    
    // MARK: - Touchdown Methods to Simulate Button Functionality
    
    
    

    
    // MARK: - Helper Function
    
    func configureViewFor(button: UIButton) {
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        button.layer.shadowRadius = 2
        button.layer.masksToBounds = false
        button.clipsToBounds = false
        button.layer.cornerRadius = 5
    }

    
    
}
