//
//  Artist.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/24/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import Foundation
import CoreData

class Artist: NSManagedObject {
    
    @NSManaged var artistID: Int
    @NSManaged var artistLinkUrl: String
    @NSManaged var artistName: String
    @NSManaged var primaryGenreName: String
    @NSManaged var releaseCount: Int
    @NSManaged var newReleases: [NewRelease]
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(searchResult: SearchResult, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Artist", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // assign all the variables using the SearchResult that is passed in
        self.artistID = searchResult.artistId
        self.artistLinkUrl = searchResult.artistLinkUrl
        self.artistName = searchResult.artistName
        self.primaryGenreName = searchResult.primaryGenreName
        
        // make a network call using lookup and the artistID to return the releaseCount that we will set to the self.variable
        let search = AppleClient()
        
        search.performLookupForArtistId(self.artistID, completion: { success, releaseCount, errorString in
            
            if success {
                self.releaseCount = releaseCount!
                
                /* Save the Core Data Context that includes the new Artist object */
                CoreDataStackManager.sharedInstance().saveContext()
            } else {
                print("Init failed")
            }
        })
       
    }
    
    
}