//
//  AppleConvenience.swift
//  TuneSentry
//
//  Created by Chris Garvey on 6/8/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import Foundation

extension AppleClient {
    
    // if an artist is added to the tracker than determine its most recent release and artwork
    func downloadDataForArtist(artistId: Int, completionHandler: (success: Bool, mostRecentRelease: Int?, mostRecentArtwork: NSData?, errorString: String?) -> Void) {
        
        // first use the lookupto determine the most recent release and the artwork URL
        performLookupForArtistId(artistId, completion: { success, collectionId, artworkUrl, errorString in
            
            if success {
                
                // then download the artwork using the artwork url
                self.downloadPhoto(artworkUrl!, completionHandler: { success, mostRecentArtwork, errorString in
                    
                    if success {
                    
                        completionHandler(success: true, mostRecentRelease: collectionId, mostRecentArtwork: nil, errorString: nil)
                        
                    } else {
                        // unable to download artwork but the most recent release is OK
                        completionHandler(success: true, mostRecentRelease: collectionId, mostRecentArtwork: nil, errorString: "Unable to download artwork")
                    }
                
                })
        
            } else {
                // unable to lookup artist
                completionHandler(success: false, mostRecentRelease: nil, mostRecentArtwork: nil, errorString: "Unable to lookup artist")
            }
    
        })
    }
    
}
