//
//  NewRelease.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/24/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import Foundation
import CoreData

class NewRelease {
    
    var collectionID: Int
    var collectionName: String
    var collectionViewUrl: String
    var artworkUrl100: String
//    var newReleaseArtwork: NSData
    var artistId: Int
    var artistName: String
    
    static var newReleases = [NewRelease]()
    
    init(artist: Artist, dictionary: [String:AnyObject]) {
        
        self.collectionID = dictionary["collectionId"] as! Int
        self.collectionName = dictionary["collectionName"] as! String
        self.collectionViewUrl = dictionary["collectionViewUrl"] as! String
        self.artworkUrl100 = dictionary["artworkUrl100"] as! String
        self.artistId = artist.artistId
        self.artistName = artist.artistName
        
//        search.downloadPhoto(self.artworkUrl100) { success, newReleaseArtwork, errorString in
//            
//            if success {
//                
//                self.newReleaseArtwork = newReleaseArtwork!
//                completion(success: true)
//            }
//        }
        
    }
}
