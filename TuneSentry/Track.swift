//
//  Track.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/24/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import Foundation
import CoreData

class Track: NSManagedObject {
    
    @NSManaged var trackName: String
    @NSManaged var trackViewUrl: String
    @NSManaged var previewUrl: String
    @NSManaged var newRelease: NewRelease
}
