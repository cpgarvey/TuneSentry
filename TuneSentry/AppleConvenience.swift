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
    func downloadDataForArtist(_ artistId: Int, completionHandler: @escaping (_ success: Bool, _ mostRecentRelease: Int?, _ mostRecentArtwork: Data?, _ errorString: String?) -> Void) {
        
        // first use the lookupto determine the most recent release and the artwork URL
        performLookupForArtistId(artistId, completion: { success, collectionId, artworkUrl, errorString in
            
            if success {
                
                // then download the artwork using the artwork url
                self.downloadPhoto(artworkUrl!, completionHandler: { success, mostRecentArtwork, errorString in
                    
                    if success {
                    
                        completionHandler(true, collectionId, mostRecentArtwork!, nil)
                        
                    } else {
                        // unable to download artwork but the most recent release is OK
                        completionHandler(true, collectionId, nil, "Unable to download artwork")
                    }
                
                })
        
            } else {
                // unable to lookup artist
                completionHandler(false, nil, nil, errorString)
            }
    
        })
    }
}
