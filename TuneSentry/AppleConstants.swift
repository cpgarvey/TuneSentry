//
//  AppleConstants.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/16/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import Foundation

extension AppleClient {
    
    // MARK: - Constants
    
    struct Constants {
        
        /* URLs */
        static let ApiScheme = "https"
        static let ApiHost = "itunes.apple.com"
        static let ApiPathSearch = "/search"
        static let ApiPathLookup = "/lookup"
        
        /* Method Arguments */
        static let LIMIT = "200"
        static let MEDIA = "music"
        
    }
    
}