//
//  NewReleaseCollectionCell.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/30/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import Foundation
import UIKit

protocol NewReleaseCollectionCellDelegate: class {
    func showUrlError(errorMessage: String)
}

class NewReleaseCollectionCell: UICollectionViewCell {
    
    // MARK - Properties
    
    @IBOutlet weak var newReleaseImage: UIImageView!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var newReleaseTitle: UILabel!
    
    var newRelease: NewRelease?
    
    var delegate: NewReleaseCollectionCellDelegate?
    
    // MARK: - Life Cycle
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.darkGrayColor().CGColor
        layer.cornerRadius = 2
        
    }
    
}
