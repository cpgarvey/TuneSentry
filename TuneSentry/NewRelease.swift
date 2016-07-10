//
//  NewRelease.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/24/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import Foundation


class NewRelease {
    
    var collectionID: Int
    var collectionName: String
    var collectionViewUrl: String
    var artworkUrl100: String
    var artistId: Int
    var artistName: String
    
    // static variables that can be accessed by other objects
    static var newReleases = [NewRelease]()
    static var artistsToCheck = 0
    static var artistsHaveBeenChecked = 0
    static var checkingForNewReleases = false
    
    init(dictionary: [String:AnyObject]) {
        self.collectionID = dictionary["collectionId"] as! Int
        self.collectionName = dictionary["collectionName"] as! String
        self.collectionViewUrl = dictionary["collectionViewUrl"] as! String
        self.artworkUrl100 = dictionary["artworkUrl100"] as! String
        self.artistId = dictionary["artistId"] as! Int
        self.artistName = dictionary["artistName"] as! String
    }
}
