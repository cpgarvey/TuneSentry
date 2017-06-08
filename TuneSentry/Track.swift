//
//  Track.swift
//  TuneSentry
//
//  Created by Chris Garvey on 6/7/17.
//  Copyright © 2017 Chris Garvey. All rights reserved.
//

import Foundation
import CoreData

class Track: NSManagedObject {
    
    @NSManaged var trackID: Int
    @NSManaged var trackName: String
    @NSManaged var trackViewUrl: String
    @NSManaged var previewUrl: String
    @NSManaged var trackPrice: Int
    @NSManaged var currency: String
    @NSManaged var trackTimeMillis: Double
    @NSManaged var collectionID: Int
    @NSManaged var collection: Collection
    
    func populateTrackFieldsWith(dictionary: [String:AnyObject], newCollection: Collection) {
        
        self.trackID = dictionary["trackId"] as! Int
        self.trackName = dictionary["trackName"] as! String
        self.trackViewUrl = dictionary["trackViewUrl"] as! String
        self.previewUrl = dictionary["previewUrl"] as! String
        self.trackPrice = dictionary["trackPrice"] as! Int
        self.currency = dictionary["currency"] as! String
        self.trackTimeMillis = dictionary["trackTimeMillis"] as! Double
        self.collectionID = newCollection.collectionID
        self.collection = newCollection
    }
    
    func convertToTime(_ millis: Double) -> String {
        
        let totalSeconds: Double = (millis/1000)
        let minutes = floor(totalSeconds/60)
        let seconds = round(totalSeconds) - (minutes * 60)
        
        if seconds < 10 {
            return "\(Int(minutes)):0\(Int(seconds))"
        } else {
            return "\(Int(minutes)):\(Int(seconds))"
        }
        
    }
}
