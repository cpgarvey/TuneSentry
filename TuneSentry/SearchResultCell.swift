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
    @IBOutlet weak var genreAndIdLabel: UILabel!
    @IBOutlet weak var addArtistToTracker: UIButton!
    @IBOutlet weak var openArtistUrlButton: UIButton!
    

    
    var searchResult: SearchResult? {
        didSet {
            
            artistNameLabel.text = searchResult!.artistName
            genreAndIdLabel.text = searchResult!.primaryGenreName + ", " + String(format: "iTunes# %d", searchResult!.artistId)
            configureViewFor(button: addArtistToTracker)
            configureViewFor(button: openArtistUrlButton)
        }
    }
    
    var isBeingTracked: Bool? {
        didSet {
            isBeingTracked! ? addArtistToTracker.setTitle("-", for: UIControlState()) : addArtistToTracker.setTitle("+", for: UIControlState())
        }
    }
    
    weak var delegate: SearchResultCellDelegate?
    
    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        /* configure whole cell to be rounded with shadow */
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
        // return button to original position
        UIView.animate(withDuration: 0.05, delay: 0.0, options: [], animations: {
            self.openArtistUrlButton.center.y -= 2.0
            self.openArtistUrlButton.layer.shadowOpacity = 0.5
        }, completion: nil)
        
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
        
        // return button to original position
        UIView.animate(withDuration: 0.05, delay: 0.0, options: [], animations: {
            self.addArtistToTracker.center.y -= 2.0
            self.addArtistToTracker.layer.shadowOpacity = 0.5
        }, completion: nil)
        
        delegate?.dismissKeyboard()
        
        if isBeingTracked! {
            delegate?.removeArtistFromTracker(searchResult!)
            isBeingTracked = false
        } else {
            delegate?.addArtistToTracker(searchResult!)
            isBeingTracked = true
        }
    }
    
    
    // MARK: - Touchdown Methods to Simulate Button Functionality
    
    
    @IBAction func openArtistUrlButtonTouchDown(_ sender: Any) {
        
        UIView.animate(withDuration: 0.05, delay: 0.0, options: [], animations: {
            self.openArtistUrlButton.center.y += 2.0
            self.openArtistUrlButton.layer.shadowOpacity = 0.0
        }, completion: nil)
        
    }
    
    @IBAction func addArtistToTrackerButtonTouchDown(_ sender: Any) {
        
        UIView.animate(withDuration: 0.05, delay: 0.0, options: [], animations: {
            self.addArtistToTracker.center.y += 2.0
            self.addArtistToTracker.layer.shadowOpacity = 0.0
        }, completion: nil)
        
        
    }
    
    
    
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
