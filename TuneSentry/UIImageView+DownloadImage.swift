//
//  UIImageView+DownloadImage.swift
//  TuneSentry
//
//  Created by Chris Garvey on 4/30/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

// citation: iOS Apprentice, 4th Edition, p. 679

import UIKit

extension UIImageView {
    func loadImageWithUrl(url: NSURL) -> NSURLSessionDownloadTask {
        let session = NSURLSession.sharedSession()
        
        let downloadTask = session.downloadTaskWithURL(url, completionHandler: {
            [weak self] url, response, error in
            
            if error == nil, let url = url,
                data = NSData(contentsOfURL: url), image = UIImage(data: data) {
                performOnMain {
                    if let strongSelf = self {
                        strongSelf.image = image
                    }
                }
            }
        })
        downloadTask.resume()
        return downloadTask
    }
    
}
