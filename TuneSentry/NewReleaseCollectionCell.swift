//
//  NewReleaseCollectionCell.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/30/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import Foundation
import UIKit

class NewReleaseCollectionCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.darkGrayColor().CGColor
        
    }
    
}
