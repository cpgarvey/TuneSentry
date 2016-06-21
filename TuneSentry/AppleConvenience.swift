//
//  AppleConvenience.swift
//  TuneSentry
//
//  Created by Chris Garvey on 6/8/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import Foundation

extension AppleClient {
    
    func downloadDataForArtist(artistId: Int, completionHandler: (success: Bool, mostRecentRelease: Int?, mostRecentArtwork: NSData, errorString: String?) -> Void) {
        
        performLookupForArtistId(artistId, completion: { success, collectionId, artworkUrl, errorString in
            
            if success {
                
                self.downloadPhoto(artworkUrl!, completionHandler: { success, mostRecentArtwork, errorString in
                    
                    if success {
                    
                        completionHandler(success: true, mostRecentRelease: collectionId, mostRecentArtwork: mostRecentArtwork!, errorString: nil)
                        
                    }
                
                })
        
            }
    
        })
    }
    
    
    
}
