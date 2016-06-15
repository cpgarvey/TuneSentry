//
//  NewRelease.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/24/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import Foundation
import CoreData

class NewRelease: NSManagedObject {
    
    @NSManaged var collectionID: Int
    @NSManaged var collectionName: String
    @NSManaged var collectionViewUrl: String
    @NSManaged var artworkUrl100: String
    @NSManaged var newReleaseArtwork: NSData
    @NSManaged var artist: Artist
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(artist: Artist, dictionary: [String:AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("NewRelease", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.collectionID = dictionary["collectionId"] as! Int
        self.collectionName = dictionary["collectionName"] as! String
        self.collectionViewUrl = dictionary["collectionViewUrl"] as! String
        self.artworkUrl100 = dictionary["artworkUrl100"] as! String
        self.artist = artist
        
        let search = AppleClient()
        
        search.downloadPhoto(self.artworkUrl100) { success, newReleaseArtwork, errorString in
            
            if success {
                
                self.newReleaseArtwork = newReleaseArtwork!
            }
        }
        
    }
}
