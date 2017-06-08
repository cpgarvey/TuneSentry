//
//  Collection.swift
//  TuneSentry
//
//  Created by Chris Garvey on 6/7/17.
//  Copyright © 2017 Chris Garvey. All rights reserved.
//

import Foundation
import CoreData


class Collection: NSManagedObject {
    
    @NSManaged var collectionID: Int
    @NSManaged var collectionType: String
    @NSManaged var artistName: String
    @NSManaged var collectionName: String
    @NSManaged var artistViewUrl: String
    @NSManaged var collectionViewUrl: String
    @NSManaged var artworkUrl100: String
    @NSManaged var collectionPrice: Double
    @NSManaged var trackCount: Int
    @NSManaged var copyright: String
    @NSManaged var releaseDate: String
    @NSManaged var primaryGenreName: String
    @NSManaged var tracks: [Track]
    
    // is there supposed to be a currency?
    
    func populateCollectionFieldsWith(dictionary: [String:AnyObject]) {
        
        self.collectionID = dictionary["collectionId"] as! Int
        self.collectionType = dictionary["collectionType"] as! String
        self.artistName = dictionary["artistName"] as! String
        self.collectionName = dictionary["collectionName"] as! String
        self.artistViewUrl = dictionary["artistViewUrl"] as! String
        self.collectionViewUrl = dictionary["collectionViewUrl"] as! String
        self.artworkUrl100 = dictionary["artworkUrl100"] as! String
        self.collectionPrice = dictionary["collectionPrice"] as! Double
        self.trackCount = dictionary["trackCount"] as! Int
        self.copyright = dictionary["copyright"] as! String
        self.releaseDate = dictionary["releaseDate"] as! String
        self.primaryGenreName = dictionary["primaryGenreName"] as! String
    }
}
