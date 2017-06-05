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
    
    // MARK - Properties
    
    @IBOutlet weak var newReleaseImage: UIImageView!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var newReleaseTitle: UILabel!
    
    var artworkUrl100: String?
    
    var newRelease: NewRelease! {
        didSet {
            
            downloadAlbumCover()
        }
    }
    
    var downloadTask: URLSessionDownloadTask?
    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.darkGray.cgColor
        layer.cornerRadius = 5
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        self.layer.shadowRadius = 2
        self.layer.masksToBounds = false
        self.clipsToBounds = false
        self.layer.cornerRadius = 5
        
    }
    
    
    // MARK: - Helper Function
    
    func downloadAlbumCover() {
        
        if let url = URL(string: artworkUrl100!) {
            downloadTask = newReleaseImage.loadImageWithUrl(url)
        }
        
    }
    
}
