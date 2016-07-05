//
//  NewRelease.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/24/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import Foundation
import CoreData

class NewRelease {
    
    var collectionID: Int
    var collectionName: String
    var collectionViewUrl: String
    var artworkUrl100: String
    var artistId: Int
    var artistName: String
    
    // use a static variable to keep an array of all new releases that can be accessed by other objects
    static var newReleases = [NewRelease]()
    
    init(artist: Artist, dictionary: [String:AnyObject]) {
        
        self.collectionID = dictionary["collectionId"] as! Int
        self.collectionName = dictionary["collectionName"] as! String
        self.collectionViewUrl = dictionary["collectionViewUrl"] as! String
        self.artworkUrl100 = dictionary["artworkUrl100"] as! String
        self.artistId = artist.artistId
        self.artistName = artist.artistName
                
    }
}
