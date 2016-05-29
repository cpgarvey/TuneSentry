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
    
    @NSManaged var artistId: Int
    @NSManaged var artistLinkUrl: String
    @NSManaged var artistName: String
    @NSManaged var primaryGenreName: String
    @NSManaged var releaseCount: Int
    @NSManaged var newReleases: [NewRelease]
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(searchResult: SearchResult, context: NSManagedObjectContext, completion: (success: Bool) -> Void) {
        let entity = NSEntityDescription.entityForName("Artist", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // assign all the variables using the SearchResult that is passed in
        self.artistId = searchResult.artistId
        self.artistLinkUrl = searchResult.artistLinkUrl
        self.artistName = searchResult.artistName
        self.primaryGenreName = searchResult.primaryGenreName
        
        // make a network call using lookup and the artistId to return the releaseCount that we will set to the self.variable
        let search = AppleClient()
        
        search.performLookupForArtistId(self.artistId, completion: { success, releaseCount, errorString in
            
            if success {
                self.releaseCount = releaseCount!
                completion(success: true)
            } else {
                print("Init failed")
                // remove the Artist that has been created?
                completion(success: false)
            }
        })
       
    }
    
    
}