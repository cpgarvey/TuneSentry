//
//  Artist+CoreDataClass.swift
//  TuneSentry
//
//  Created by Chris Garvey on 4/12/17.
//  Copyright © 2017 Chris Garvey. All rights reserved.
//

import Foundation

import CoreData

protocol ArtistDelegate: class {
    func updateNewReleasesView()
}


class Artist: NSManagedObject {
    
    public var delegate: ArtistDelegate?
    
    public static var trackedArtists: [Artist]?
    
    func populateArtistFieldsWith(searchResult: SearchResult, completion: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
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
                    DispatchQueue.main.async {
                        self.mostRecentRelease = mostRecentRelease!
                        self.mostRecentArtwork = mostRecentArtwork!
                        completion(true, nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.mostRecentRelease = mostRecentRelease!
                        self.mostRecentArtwork = nil
                        completion(true, nil)
                    }
                }
                
            } else {
                print("Unable to download most recent release and artwork")
                completion(false, errorString)
            }
        })
    }
    
    func checkForNewRelease() {
        let now = NSDate()
        print("\(self.artistId): \(now)")
        let search = AppleClient()
        
        search.checkNewRelease(self.artistId, mostRecentRelease: self.mostRecentRelease) { success, newReleases, updatedMostRecentRelease, errorString in
            
            if success && !newReleases.isEmpty {
                
                
                for newRelease in newReleases {
                    NewRelease.newReleases.append(newRelease)
                    NewRelease.newReleases.sort {
                        $0.artistName.localizedCaseInsensitiveCompare($1.artistName) == ComparisonResult.orderedAscending
                    }
                }
                
                // notify the delegate there are new releases so update the collection view
                DispatchQueue.main.async {
                    self.mostRecentRelease = updatedMostRecentRelease!
                    NewRelease.artistsHaveBeenChecked += 1
                    print("Artists checked: \(NewRelease.artistsHaveBeenChecked)")
                    if NewRelease.artistsToCheck == NewRelease.artistsHaveBeenChecked {
                        self.delegate?.updateNewReleasesView()
                        print("Reload called from Artist")
                    }
                    
                }
                
            } else {
                print("No new releases")
                NewRelease.artistsHaveBeenChecked += 1
                if NewRelease.artistsToCheck == NewRelease.artistsHaveBeenChecked {
                    NewRelease.checkingForNewReleases = false
                    self.delegate?.updateNewReleasesView()
                    print("Reload called from Artist")
                }
            }
        }
    }
}
