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
    
    @NSManaged var artistID: Int64
    @NSManaged var artistLinkUrl: String
    @NSManaged var artistName: String
    @NSManaged var primaryGenreName: String
    @NSManaged var releaseCount: Int64
    @NSManaged var newReleases: [NewRelease]
    
    
}