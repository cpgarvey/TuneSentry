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
    
    @NSManaged var collectionType: String
    @NSManaged var collectionID: Int64
    @NSManaged var collectionName: String
    @NSManaged var trackCount: Int64
    @NSManaged var releaseDate: String
    @NSManaged var country: String
    @NSManaged var collectionViewUrl: String
    @NSManaged var artworkUrl30: String
    @NSManaged var artworkUrl60: String
    @NSManaged var artworkUrl100: String
    @NSManaged var artist: Artist
    @NSManaged var tracks: [Track]
    
}
