//
//  ArtistCell.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/29/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import Foundation
import UIKit

class ArtistCell: UICollectionViewCell {
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderColor = UIColor.lightGrayColor().CGColor
        layer.borderWidth = 1
        layer.cornerRadius = 3
        layer.shadowColor = UIColor.grayColor().CGColor
        layer.shadowOffset = CGSizeMake(0, 0.5)
        layer.shadowOpacity = 0.5
        layer.masksToBounds = false
        
    }
    
}
