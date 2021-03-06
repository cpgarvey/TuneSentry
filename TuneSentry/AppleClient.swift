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

// define completion handlers for convenience
typealias SearchComplete = (_ success: Bool, _ errorString: String?, _ results: [SearchResult]?) -> Void
typealias LookupComplete = (_ success: Bool, _ collectionId: Int?, _ artworkUrl: String?, _ errorString: String?) -> Void
typealias NewReleaseCheckComplete = (_ success: Bool, _ newReleases: [NewRelease], _ updatedMostRecentRelease: Int?,  _ errorString: String?) -> Void

class AppleClient: NSObject {
    
    /* Enum to track the state of the searching by the client */
    enum SearchState {
        case notSearchedYet
        case searching
        case error
        case noResults
        case results([SearchResult]) // the .Results case has an "associated value" of an array of Artists
        case newReleases([NewRelease]) // the .NewReleases case has an associated value of an array of new releases
    }
    
    /* Use set parameter on private variable to indicate that other objects can read the variable but cannot assign new values to it */
    fileprivate(set) var state: SearchState = .notSearchedYet
    
    fileprivate var dataTaskSearch: URLSessionDataTask? = nil
    fileprivate var dataTaskLookup: URLSessionDataTask? = nil
    fileprivate var dataTaskNewRelease: URLSessionDataTask? = nil
    
    
    // MARK: - API Functionality
    
    func performSearchForText(_ text: String, completion: @escaping SearchComplete) {
        
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
            
            // if there is an active data task, then cancel it so we can begin a new one
            dataTaskSearch?.cancel()
            
            // set the state of the search
            state = .searching
            
            let url = constructSearchURL(withTermDictionary as [String : AnyObject], search: true)
            let session = URLSession.shared
            dataTaskSearch = session.dataTask(with: url, completionHandler: { data, response, error in
                
                if let error = error, (error as NSError).code == -999 {
                    self.state = .notSearchedYet
                    return // search was cancelled
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                    let data = data, let dictionary = self.parseJSON(data) {
                    
                    let searchResults = self.parseDictionaryForSearch(dictionary)
                    
                    if searchResults.isEmpty {
                        let noResults = [SearchResult]()
                        self.state = .noResults
                        completion(true, nil, noResults)
                        return
                    } else {
                        self.state = .results(searchResults)
                        completion(true, nil, searchResults)
                        return
                    }
                    
                } else {
                    self.state = .error
                    completion(false, nil, nil)
                    return
                }
            })
            
            dataTaskSearch?.resume()
        }
    }
    
    
    func performLookupForArtistId(_ artistId: Int, completion: @escaping LookupComplete) {
        
        /* Set the parameters of the search */
        let methodArguments = [
            "id": String(artistId),
            "entity": "album",
            "sort": "recent",
            "limit": "1"
        ]
        
        let url = constructSearchURL(methodArguments as [String : AnyObject], search: false)
        let session = URLSession.shared
        dataTaskLookup = session.dataTask(with: url, completionHandler: { data, response, error in
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                let data = data, let dictionary = self.parseJSON(data) {
                
                guard let results = dictionary["results"] as? [[String:AnyObject]] else {
                    completion(false, nil, nil, "results failed")
                    return
                }
                
                if results.count > 1 {
                    
                    // find the most recent collection id that will be used to check for new releases in the future
                    guard let collectionId = results[1]["collectionId"] as? Int else {
                        completion(false, nil, nil, "Determining most recent release failed: cannot add to tracker")
                        return
                    }
                    
                    // obtain the most recent artwork so that it can be displayed with the artist cell
                    guard let mostRecentArtworkUrl = results[1]["artworkUrl100"] as? String else {
                        completion(false, nil, nil, "Determining artwork failed: cannot add to tracker")
                        return
                    }
                    
                    completion(true, collectionId, mostRecentArtworkUrl, nil)
                    return
                    
                } else {
                    completion(false, nil, nil, "No releases for artist: cannot add to tracker")
                }
            } else {
                completion(false, nil, nil, "Unable to lookup artist: cannot add to tracker")
                return
            }
        })
        
        dataTaskLookup?.resume()
    
    }

    func checkNewRelease(_ artistId: Int, mostRecentRelease: Int, completion: @escaping NewReleaseCheckComplete) {
        
        /* Set the parameters of the search */
        let methodArguments = [
            "id": String(artistId),
            "entity": "album",
            "sort": "recent",
            "limit": "10" // we're going to limit our search to the 10 most recent releases
        ]
        
        var newReleases = [NewRelease]()
        
        let url = constructSearchURL(methodArguments as [String : AnyObject], search: false)
        let session = URLSession.shared
        dataTaskNewRelease = session.dataTask(with: url, completionHandler: { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                let data = data, let dictionary = self.parseJSON(data) {
                
                guard let results = dictionary["results"] as? [[String:AnyObject]] else {
                    completion(false, newReleases, nil, "results failed")
                    return
                }
                
                if results.count > 1 {
                    
                    guard let firstCollectionId = results[1]["collectionId"] as? Int else {
                        completion(false, newReleases, nil, "results failed")
                        return
                    }

                    // check to see if the first id in the results matches the most recent release for the artist... if so, no new releases
                    if firstCollectionId == mostRecentRelease {
                        completion(true, newReleases, nil, nil)
                        return
                    }
                    
                    // if the function makes it this far, there are new releases to return
                    for result in results where result["wrapperType"] as? String == "collection" {
                        
                        if result["collectionId"] as? Int == mostRecentRelease {
                            // if the loop has reached the artist's most recent release, then update the most recent release to the first id
                            completion(true, newReleases, firstCollectionId, nil)
                            return
                        } else {
                            let newRelease = NewRelease(dictionary: result)
                            newReleases.append(newRelease)
                        }
                    }
                    
                    
                    /* For testing purposes to see example of new releases: Comment out lines 183 - 199, then uncomment lines 203 - 208 and restart app with artists already saved */
                   
//                                    for result in results where result["wrapperType"] as? String == "collection" {
//                                        let newRelease = NewRelease(dictionary: result)
//                                        newReleases.append(newRelease)
//                                        
//                                    }
                    
                    // call the completion handler in the event that the loop goes through all of the results and doesn't hit the mostRecentRelease
                    completion(true, newReleases, firstCollectionId, nil)
                    return
                    
                } else {
                    completion(false, newReleases, nil, "No releases available to check")
                    return
                }
                
                
            } else {
                completion(false, newReleases, nil, "results failed")
            }
        }) 
        
        dataTaskNewRelease?.resume()
        
    }
    
    func downloadPhoto(_ artworkUrl: String, completionHandler: @escaping (_ success: Bool, _ mostRecentArtwork: Data?, _ errorString: String?) -> Void) {
        
        let session = URLSession.shared
        let imageURL = URL(string: artworkUrl)
        
        let sessionTask = session.dataTask(with: imageURL!, completionHandler: { data, response, error in
            
            /* GUARD: Was data returned? */
            guard let data = data else {
                completionHandler(false, nil, error?.localizedDescription)
                return
            }
            
            completionHandler(true, data, nil)
            
        }) 
        
        sessionTask.resume()
    }

    
    // MARK: - Helper Functions

    /* Construct an iTunes Search URL from parameters */
    func constructSearchURL(_ parameters: [String:AnyObject]?, search: Bool) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        if search {
            components.path = Constants.ApiPathSearch
        } else {
            components.path = Constants.ApiPathLookup
        }
        
        components.queryItems = [URLQueryItem]()
        
        if parameters != nil {
            
            for (key, value) in parameters! {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
            
        }
        
        return components.url!
    }
    
    /* Parse JSON into swift readable dictionary */
    fileprivate func parseJSON(_ data: Data) -> [String: AnyObject]? {
        
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
        } catch {
            print("JSON Error: \(error)")
            return nil
        }
        
    }
    
    /* Parse the dictionary to return an array of search results */
    fileprivate func parseDictionaryForSearch(_ dictionary: [String: AnyObject]) -> [SearchResult] {
        
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
    fileprivate func parseSearchResult(_ dictionary: [String: AnyObject]) -> SearchResult {
        var searchResult = SearchResult()

        if let artistId = dictionary["artistId"] as? Int {
            searchResult.artistId = artistId
        }
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artistLinkUrl = dictionary["artistLinkUrl"] as! String
        
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.primaryGenreName = genre
        }
        
        return searchResult
    }

}

