//
//  AppleClient.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/16/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import Foundation
import UIKit
import CoreData


typealias SearchComplete = (success: Bool, errorString: String?) -> Void
typealias LookupComplete = (success: Bool, collectionId: Int?, artworkUrl: String?, errorString: String?) -> Void
typealias NewReleaseCheckComplete = (success: Bool, newReleases: [NewRelease]?, errorString: String?) -> Void

class AppleClient: NSObject {
    
    /* Enum to track the state of the searching by the client */
    enum SearchState {
        case NotSearchedYet
        case Searching
        case Error
        case NoResults
        case Results([SearchResult]) // the .Results case has an "associated value" of an array of Artists
        case NewReleases([NewRelease]) // the .NewReleases case has an associated value of an array of new releases
    }
    
    /* Use set parameter on private variable to indicate that other objects can read the variable but cannot assign new values to it */
    private(set) var state: SearchState = .NotSearchedYet
    
    private var dataTaskSearch: NSURLSessionDataTask? = nil
    private var dataTaskLookup: NSURLSessionDataTask? = nil
    private var dataTaskNewRelease: NSURLSessionDataTask? = nil
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    
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
                    
                    let searchResults = self.parseDictionaryForSearch(dictionary)
                    if searchResults.isEmpty {
                        self.state = .NoResults
                    } else {
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
            "id": String(artistId),
            "entity": "album",
            "sort": "recent",
            "limit": "1"
        ]
        
        let url = constructSearchURL(methodArguments, search: false)
        let session = NSURLSession.sharedSession()
        dataTaskLookup = session.dataTaskWithURL(url, completionHandler: { data, response, error in
            
            if let httpResponse = response as? NSHTTPURLResponse
                where httpResponse.statusCode == 200,
                let data = data, dictionary = self.parseJSON(data) {
                
                //print(dictionary)
                guard let results = dictionary["results"] as? [[String:AnyObject]] else {
                    completion(success: false, collectionId: nil, artworkUrl: nil, errorString: "results failed")
                    return
                }
                
                guard let collectionId = results[1]["collectionId"] as? Int else {
                    completion(success: false, collectionId: nil, artworkUrl: nil, errorString: "determining collectionID failed")
                    return
                }
                
                guard let mostRecentArtworkUrl = results[1]["artworkUrl100"] as? String else {
                    completion(success: false, collectionId: nil, artworkUrl: nil, errorString: "determining artworkUrl failed")
                    return
                }
                
                completion(success: true, collectionId: collectionId, artworkUrl: mostRecentArtworkUrl, errorString: nil)
                
            } else {
                completion(success: false, collectionId: nil, artworkUrl: nil, errorString: "Unable to lookup artist")
            }
            
        })
        
        dataTaskLookup?.resume()
    
    }

    func checkNewRelease(artist: Artist, completion: NewReleaseCheckComplete) {
        
        /* Set the parameters of the search */
        let methodArguments = [
            "id": String(artist.artistId),
            "entity": "album",
            "sort": "recent",
            "limit": "10"
        ]
        
        var newReleases = [NewRelease]()
        
        let url = constructSearchURL(methodArguments, search: false)
        let session = NSURLSession.sharedSession()
        dataTaskNewRelease = session.dataTaskWithURL(url) { (data, response, error) in
            
            if let httpResponse = response as? NSHTTPURLResponse
                where httpResponse.statusCode == 200,
                let data = data, dictionary = self.parseJSON(data) {
                
                //print(dictionary)
                guard let results = dictionary["results"] as? [[String:AnyObject]] else {
                    completion(success: false, newReleases: nil, errorString: "results failed")
                    return
                }
                
                guard let firstCollectionId = results[1]["collectionId"] as? Int else {
                    completion(success: false, newReleases: nil, errorString: "results failed")
                    return
                }
                
                // maybe a recursive function here that will keep checking the id until it gets to the mostRecentRelease?
//                if firstCollectionId == artist.mostRecentRelease {
//                    completion(success: true, newReleases: newReleases, errorString: nil)
//                    return
//                }
                
                for result in results where result["wrapperType"] as? String == "collection" {
//                    
//                    if result["collectionId"] as? Int == artist.mostRecentRelease {
//                        completion(success: true, newReleases: newReleases, errorString: nil)
//                    } else {
                    let newRelease = NewRelease(artist: artist, dictionary: result)
                    newReleases.append(newRelease)
                }
                        
                                // call the completion handler in the event that the loop goes through all of the results and doesn't hit the artist.mostRecentRelease
                completion(success: true, newReleases: newReleases, errorString: nil)
                
            } else {
                completion(success: false, newReleases: nil, errorString: "results failed")
            }
            
        }
        
        dataTaskNewRelease?.resume()
        
    }
    
    func downloadPhoto(artworkUrl: String, completionHandler: (success: Bool, mostRecentArtwork: NSData?, errorString: String?) -> Void) {
        
        let session = NSURLSession.sharedSession()
        let imageURL = NSURL(string: artworkUrl)
        
        let sessionTask = session.dataTaskWithURL(imageURL!) { data, response, error in
            
            /* GUARD: Was data returned? */
            guard let data = data else {
                completionHandler(success: false, mostRecentArtwork: nil, errorString: error?.localizedDescription)
                return
            }
            
            completionHandler(success: true, mostRecentArtwork: data, errorString: nil)
            
        }
        
        sessionTask.resume()
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
            print("artistId Success!")
        }
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artistLinkUrl = dictionary["artistLinkUrl"] as! String
        
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.primaryGenreName = genre
        }
        
        return searchResult
    }
    
    
}

