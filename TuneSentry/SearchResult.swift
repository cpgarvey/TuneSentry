//
//  SearchResult.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/17/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import Foundation

class SearchResult {
    
    //var artistID: Int64 = 0
    var artistName = ""
    var genre = ""
    var artistLinkUrl = ""
    
    var inWatchlist = false
    
    static var artistWatchList = [SearchResult]()

}