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
}

class SearchResultCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var viewIniTunesButton: UIButton!
    @IBOutlet weak var addArtistToTracker: UIButton!
    
    var artistUrl: String?
    
    weak var delegate: SearchResultCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    // MARK: - Action
    
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
    
    
}
