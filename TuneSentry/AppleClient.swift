//
//  AppleClient.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/16/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import Foundation
import UIKit


typealias SearchComplete = (success: Bool, errorString: String?) -> Void
typealias LookupComplete = (success: Bool, releaseCount: Int?, errorString: String?) -> Void

class AppleClient: NSObject {
    
    /* Enum to track the state of the searching by the client */
    enum SearchState {
        case NotSearchedYet
        case Searching
        case Error
        case NoResults
        case Results([SearchResult]) // the .Results case has an "associated value" of an array of Artists
    }
    
    /* Use set parameter on private variable to indicate that other objects can read the variable but cannot assign new values to it */
    private(set) var state: SearchState = .NotSearchedYet
    
    private var dataTaskSearch: NSURLSessionDataTask? = nil
    private var dataTaskLookup: NSURLSessionDataTask? = nil
    
    
    // MARK: - API Functionality
    
    func performSearchForText(text: String, completion: SearchComplete) {
        
        if !text.isEmpty {
            
            /* Set the parameters of the search */
            let methodArguments = [
                "limit": Constants.LIMIT,
                "media": Constants.MEDIA,
                "entity": "musicArtist",
                "attribute": "artistTerm"
            ]
            
            /* Add the variable page argument to the method */
            var withTermDictionary = methodArguments
            withTermDictionary["term"] = text
            
            
            // if there is an active data task, then cancel it
            dataTaskSearch?.cancel()
            
            // activate the network activity indicator
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            // set the state of the search
            state = .Searching
            
            let url = constructSearchURL(withTermDictionary, search: true)
            let session = NSURLSession.sharedSession()
            dataTaskSearch = session.dataTaskWithURL(url, completionHandler: { data, response, error in
                self.state = .NotSearchedYet
                var success = false
                if let error = error where error.code == -999 {
                    return // search was cancelled
                }
                
                if let httpResponse = response as? NSHTTPURLResponse
                    where httpResponse.statusCode == 200,
                    let data = data, dictionary = self.parseJSON(data) {
                    
                    var searchResults = self.parseDictionaryForSearch(dictionary)
                    if searchResults.isEmpty {
                        self.state = .NoResults
                    } else {
                        //searchResults.sortInPlace(<)
                        self.state = .Results(searchResults)
                    }
                    
                    success = true
                    print(dictionary)
                    
                } else {
                    self.state = .Error
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    completion(success: success, errorString: nil)
                }
            })
            
            dataTaskSearch?.resume()
        }
    }
    
    
    func performLookupForArtistId(artistId: Int, completion: LookupComplete) {
        
        /* Set the parameters of the search */
        let methodArguments = [
            "id": String(artistId)
        ]
        
        let url = constructSearchURL(methodArguments, search: false)
        let session = NSURLSession.sharedSession()
        dataTaskLookup = session.dataTaskWithURL(url, completionHandler: { data, response, error in
            
            if let httpResponse = response as? NSHTTPURLResponse
                where httpResponse.statusCode == 200,
                let data = data, dictionary = self.parseJSON(data) {
                
                guard let releaseCount = dictionary["resultCount"] as? Int else {
                    completion(success: false, releaseCount: nil, errorString: "resultCount failed")
                    return
                }
                
                completion(success: true, releaseCount: (releaseCount - 1), errorString: nil)
                
            } else {
                completion(success: false, releaseCount: nil, errorString: "Unable to lookup artist")
            }
            
        })
        
        dataTaskLookup?.resume()
    
    }


    // MARK: - Helper Functions

    /* Construct a iTunes Search URL from parameters */
    func constructSearchURL(parameters: [String:AnyObject]?, search: Bool) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        if search {
            components.path = Constants.ApiPathSearch
        } else {
            components.path = Constants.ApiPathLookup
        }
        
        components.queryItems = [NSURLQueryItem]()
        
        if parameters != nil {
            
            for (key, value) in parameters! {
                let queryItem = NSURLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
            
        }
        
        return components.URL!
    }
    
    /* Parse JSON */
    private func parseJSON(data: NSData) -> [String: AnyObject]? {
        
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]
        } catch {
            print("JSON Error: \(error)")
            return nil
        }
        
    }
    
    /* Parse the JSON */
    private func parseDictionaryForSearch(dictionary: [String: AnyObject]) -> [SearchResult] {
        
        guard let array = dictionary["results"] as? [AnyObject] else {
            print("Expected 'results' array")
            return []
        }
        
        var searchResults = [SearchResult]()
        
        
        for resultDict in array {
            if let resultDict = resultDict as? [String: AnyObject] {
                
                var searchResult: SearchResult?
                
                searchResult = parseSearchResult(resultDict)
                
                if let result = searchResult {
                    searchResults.append(result)
                }
            }
            
        }
        
        return searchResults
    }
    
    
    /* Parse the search result dictionary */
    private func parseSearchResult(dictionary: [String: AnyObject]) -> SearchResult {
        let searchResult = SearchResult()

        if let artistId = dictionary["artistId"] as? Int {
            searchResult.artistId = artistId
            print("artistID Success!")
        }
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artistLinkUrl = dictionary["artistLinkUrl"] as! String
        
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.primaryGenreName = genre
        }
        
        return searchResult
    }
    
    
}

