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
    
    var searchResult: SearchResult?
    
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
            guard UIApplication.shared.openURL(url) else {
                delegate?.showUrlError("There was an error opening this Artist in iTunes.")
                return
            }
        } else {
            delegate?.showUrlError("There was an error opening this Artist in iTunes.")
        }
    }
    
    
    @IBAction func addArtistToWatchlist(_ sender: UIButton) {
        delegate?.dismissKeyboard()
        if searchResult!.inTracker {
            // if the artist is already being tracked, then send a message to the delegate removing the artist
            delegate?.removeArtistFromTracker(searchResult!)
        } else {
            // otherwise tell the delegat to add the artist to the tracker
            delegate?.addArtistToTracker(searchResult!)
        }
        
    }
    
}
