//
//  UIImageView+DownloadImage.swift
//  StoreSearch
//
//  Created by Chris Garvey on 4/30/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

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
