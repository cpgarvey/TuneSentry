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
    
    init(searchResult: SearchResult, context: NSManagedObjectContext, completion: (success: Bool, errorString: String?) -> Void) {
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
                    performOnMain {
                        self.mostRecentRelease = mostRecentRelease!
                        self.mostRecentArtwork = mostRecentArtwork!
                        completion(success: true, errorString: nil)
                    }
                } else {
                    performOnMain {
                        self.mostRecentRelease = mostRecentRelease!
                        self.mostRecentArtwork = nil
                        completion(success: true, errorString: nil)
                    }
                }
                
            } else {
                print("Init failed")
                completion(success: false, errorString: errorString)
            }
        })
       
    }
    
    func checkForNewRelease() {
        
        let search = AppleClient()
        
        search.checkNewRelease(self.artistId, mostRecentRelease: self.mostRecentRelease) { success, newReleases, updatedMostRecentRelease, errorString in
            
            if success && !newReleases.isEmpty {
                
                
                for newRelease in newReleases {
                    NewRelease.newReleases.append(newRelease)
                    NewRelease.newReleases.sortInPlace {
                        $0.artistName.localizedCaseInsensitiveCompare($1.artistName) == NSComparisonResult.OrderedAscending
                    }
                }
                
                // notify the delegate there are new releases so update the collection view 
                performOnMain {
                    self.mostRecentRelease = updatedMostRecentRelease!
                    NewRelease.artistsHaveBeenChecked += 1
                    print("Artists checked: \(NewRelease.artistsHaveBeenChecked)")
                    if NewRelease.artistsToCheck == NewRelease.artistsHaveBeenChecked {
                        self.delegate?.updateNewReleasesCollectionView()
                        print("Reload called from Artist")
                    }
                    
                }
                
            } else {
                print("No new releases")
                NewRelease.artistsHaveBeenChecked += 1
                if NewRelease.artistsToCheck == NewRelease.artistsHaveBeenChecked {
                    self.delegate?.updateNewReleasesCollectionView()
                    print("Reload called from Artist")
                }
            }
        }
    }
    
}