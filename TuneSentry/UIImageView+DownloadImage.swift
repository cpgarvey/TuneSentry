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
    func loadImageWithUrl(_ url: URL) -> URLSessionDownloadTask {
        let session = URLSession.shared
        
        let downloadTask = session.downloadTask(with: url, completionHandler: {
            [weak self] url, response, error in
            
            if error == nil, let url = url,
                let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
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
