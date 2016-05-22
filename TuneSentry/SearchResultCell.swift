//
//  SearchResultCell.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/17/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import UIKit


protocol SearchResultCellDelegate: class {
    func showUrlError(errorMessage: String)
    func showHUD(action: HudView.WatchlistAction)
}

class SearchResultCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var viewIniTunesButton: UIButton!
    @IBOutlet weak var addArtistToTracker: UIButton!
    
    var artistUrl: String?
    var inWatchlist = false
    
    weak var delegate: SearchResultCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    // MARK: - Actions
    
    @IBAction func openArtistUrl(sender: UIButton) {
        
        if let url = NSURL(string: artistUrl!) {
            guard UIApplication.sharedApplication().openURL(url) else {
                delegate?.showUrlError("There was an error opening this Artist in iTunes.")
                return
            }
        } else {
            delegate?.showUrlError("There was an error opening this Artist in iTunes.")
        }
    }
    
    
    @IBAction func addArtistToWatchlist(sender: UIButton) {
        
        if inWatchlist {
            delegate?.showHUD(HudView.WatchlistAction.Remove)
        } else {
            delegate?.showHUD(HudView.WatchlistAction.Add)
        }
        
    }
    
    
    
}
