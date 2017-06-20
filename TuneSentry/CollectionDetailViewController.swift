////
////  CollectionDetailViewController.swift
////  TuneSentry
////
////  Created by Chris Garvey on 6/7/17.
////  Copyright © 2017 Chris Garvey. All rights reserved.
////
//
//import UIKit
//import CoreData
//import AVFoundation
//
//private let dateFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateStyle = .medium
//    return formatter
//}()
//
//class CollectionDetailViewController: UIViewController {
//    var player: AVPlayer?
//    
//    var collectionID: Int?
//    var collection: Collection?
//    var inWishlist: Bool?
//    var currentWishlist: [Collection]?
//    var currentlyDownloading = false
//    
//    @IBOutlet weak var downloadingView: UIView!
//    @IBOutlet weak var artistName: UILabel!
//    @IBOutlet weak var collectionName: UILabel!
//    @IBOutlet weak var collectionPrice: UILabel!
//    @IBOutlet weak var trackCount: UILabel!
//    @IBOutlet weak var copyright: UILabel!
//    @IBOutlet weak var releaseDate: UILabel!
//    @IBOutlet weak var primaryGenreName: UILabel!
//    @IBOutlet weak var collectionImage: UIImageView!
//    @IBOutlet weak var trackTable: UITableView!
//    @IBOutlet weak var wishlistButton: UIButton!
//    @IBOutlet weak var statusLabel: UILabel!
//    
//    
//    var downloadTask: URLSessionDownloadTask?
//    
//    var tracks: [Track]? {
//        didSet {
//            trackTable.reloadData()
//        }
//    }
//    
//    
//    /* Core Data Convenience */
//    lazy var sharedContext: NSManagedObjectContext = {
//        return CoreDataStackManager.sharedInstance().managedObjectContext
//    }()
//    
//    
//    let search = AppleClient()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        trackTable.register(UINib(nibName: "TrackNib", bundle: nil), forCellReuseIdentifier: "TrackNib")
//        trackTable.dataSource = self
//        
//        if collection != nil {
//            print("Collection isn't nil")
//            performOnMain {
//                self.tracks = self.collection?.tracks
//                self.setupLabels()
//                self.setupButton()
//                self.downloadAlbumCover()
//                self.downloadingView.alpha = 0
//            }
//            
//        } else {
//            
//            
//            search.performLookupForCollectionId(collectionID!) { success, collection, tracks, error in
//                self.currentlyDownloading = true
//                print("have to look up artist and tracks")
//                if !success {
//                    print("success is false")
//                    print(error!)
//                    self.currentlyDownloading = false
//                    self.statusLabel.text = "There was an error contacting the iTunes store. Please try again later"
//                    self.downloadingView.alpha = 1
//                    // we need to display an error message then to try again later
//                }
//                
//                
//                if success {
//                    self.currentlyDownloading = false
//                    print("success is true")
//                    performOnMain {
//                        
//                        self.collection = collection!
//                        print(collection)
//                        self.tracks = collection!.tracks
//                        print(tracks)
//                        self.setupLabels()
//                        self.setupButton()
//                        self.downloadAlbumCover()
//                        self.downloadingView.alpha = 0
//                    }
//                }
//                
//            }
//            
//        }
//        
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        player = nil
//        
//        if currentlyDownloading {
//            return
//        } else {
//            if inWishlist == true {
//                
//                performOnMain {
//                    CoreDataStackManager.sharedInstance().saveContext()
//                }
//                
//            } else {
//                
//                if self.collection != nil {
//                    performOnMain {
//                        
//                        self.sharedContext.delete(self.collection!)
//                        CoreDataStackManager.sharedInstance().saveContext()
//                    }
//                }
//                
//                
//            }
//            
//        }
//        
//    }
//    
//    
//    @IBAction func wishlistAction(_ sender: UIButton) {
//        
//        print(inWishlist)
//        
//        if inWishlist == true {
//            inWishlist = false
//            
//            /* show the user a removal HUD */
//            //showHUD(HudView.TrackerAction.Remove)
//            
//            /* reload the table data */
//            setupButton()
//            
//        } else {
//            inWishlist = true
//            print(inWishlist)
//            
//            /* show HUD indicating to user that Artist was saved */
//            //self.showHUD(HudView.TrackerAction.Add)
//            
//            /* reset the button */
//            setupButton()
//        }
//    }
//    
//    // MARK: - Helper Functions
//    
//    func downloadAlbumCover() {
//        
//        if let url = URL(string: collection!.artworkUrl100) {
//            downloadTask = collectionImage.loadImageWithUrl(url)
//        }
//        
//    }
//    
//    func setupLabels() {
//        
//        let stringDate = collection?.releaseDate
//        let dateFormat = DateFormatter()
//        dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//        
//        let date = dateFormat.date(from: stringDate!)
//        
//        artistName.text = collection!.artistName
//        collectionName.text = collection!.collectionName
//        releaseDate.text = "Release Date: \(formatDate(date!))"
//        primaryGenreName.text = collection!.primaryGenreName
//    }
//    
//    func setupButton() {
//        
//        performOnMain {
//            if self.inWishlist == true {
//                self.wishlistButton.setTitle("Remove from Wishlist", for: UIControlState())
//            } else {
//                self.wishlistButton.setTitle("Add to Wishlist", for: UIControlState())
//            }
//        }
//    }
//    
//    
//    func formatDate(_ date: Date) -> String {
//        return dateFormatter.string(from: date)
//    }
//    
//    
//}
//
//
//extension CollectionDetailViewController: UITableViewDataSource, UITableViewDelegate, TrackNibCellDelegate {
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        
//        if tracks == nil {
//            return 0
//        } else {
//            return (tracks?.count)!
//        }
//        
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackNib", for: indexPath) as! TrackNib
//        let track = tracks?[(indexPath as NSIndexPath).row]
//        
//        cell.trackNumber.setTitle("\((indexPath as NSIndexPath).row + 1).", for: .normal)
//        cell.trackName.text = track?.trackName
//        cell.trackLength.text = track?.convertToTime((track?.trackTimeMillis)!)
//        cell.delegate = self
//        cell.track = track
//        
//        return cell
//    }
//    
//    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    //        print("Selected a track...")
//    //        let track = tracks![(indexPath as NSIndexPath).row] as Track
//    //        playPreview(track)
//    //    }
//    
//    internal func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        return nil
//    }
//    
//}
//
//
//// MARK: - AV Functionality
//
//extension CollectionDetailViewController {
//    
//    func playPreview(_ track: Track) {
//        print("Should be playing...")
//        let url = track.previewUrl
//        let playerItem = AVPlayerItem( url:URL( string:url )! )
//        
//        player = AVPlayer(playerItem:playerItem)
//        player?.rate = 1.0
//        player?.play()
//    }
//}
//
//
//
//
