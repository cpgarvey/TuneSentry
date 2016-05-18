//
//  SearchResultCell.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/17/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
