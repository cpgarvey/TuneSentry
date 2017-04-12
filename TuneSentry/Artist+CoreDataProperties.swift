//
//  Artist.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/24/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import Foundation
import CoreData

extension Artist {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Artist> {
        return NSFetchRequest<Artist>(entityName: "Artist");
    }
    
    @NSManaged public var artistId: Int
    @NSManaged public var artistLinkUrl: String
    @NSManaged public var artistName: String
    @NSManaged public var primaryGenreName: String
    @NSManaged public var mostRecentRelease: Int
    @NSManaged public var mostRecentArtwork: Data?
    
}
