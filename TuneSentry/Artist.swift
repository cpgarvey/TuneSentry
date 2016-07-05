//
//  Artist.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/24/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import Foundation
import CoreData

protocol ArtistDelegate: class {
    func updateNewReleasesCollectionView()
}


class Artist: NSManagedObject {
    
    @NSManaged var artistId: Int
    @NSManaged var artistLinkUrl: String
    @NSManaged var artistName: String
    @NSManaged var primaryGenreName: String
    @NSManaged var mostRecentRelease: Int
    @NSManaged var mostRecentArtwork: NSData?
    
    var delegate: ArtistDelegate?
    
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
        
        // make a network call using lookup and the artistId to return the most recent release that we will set to the self.variable
        let search = AppleClient()
        
        search.downloadDataForArtist(self.artistId, completionHandler: { success, mostRecentRelease, mostRecentArtwork, errorString in
            
            if success {
                
                if mostRecentArtwork != nil {
                    self.mostRecentRelease = mostRecentRelease!
                    self.mostRecentArtwork = mostRecentArtwork!
                    completion(success: true)
                } else {
                    self.mostRecentRelease = mostRecentRelease!
                    self.mostRecentArtwork = nil
                    completion(success: true)
                }
                
            } else {
                print("Init failed")
                completion(success: false)
            }
        })
       
    }
    
    func checkForNewRelease() {
        
        let search = AppleClient()
        
        search.checkNewRelease(self) { success, newReleases, errorString in
            
            if success && !newReleases.isEmpty {
                
                for newRelease in newReleases {
                    NewRelease.newReleases.append(newRelease)
                    NewRelease.newReleases.sortInPlace {
                        $0.artistName.localizedCaseInsensitiveCompare($1.artistName) == NSComparisonResult.OrderedAscending
                    }
                }
                
                self.delegate?.updateNewReleasesCollectionView()
                
            }
        }
    }
    
}