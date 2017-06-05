//
//  NewReleaseCollectionView.swift
//  TuneSentry
//
//  Created by Chris Garvey on 6/3/17.
//  Copyright © 2017 Chris Garvey. All rights reserved.
//

import UIKit

protocol NewReleaseCollectionViewDelegate: class {
    func showUrlError(_ errorMessage: String)
}

class NewReleaseCollectionView: UICollectionView {
    
    weak var newReleaseCollectionViewDelegate: NewReleaseCollectionViewDelegate?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        // do the setup for the collection view
        dataSource = self
        delegate = self
        
        self.backgroundColor = UIColor.clear
        
        let  cellNib = UINib(nibName: "NewReleaseCollectionCell", bundle: nil)
        self.register(cellNib, forCellWithReuseIdentifier: "NewReleaseCollectionCell")
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NewReleaseCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let height = 182
        let width = 128
        return CGSize(width: width, height: height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return NewRelease.newReleases.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewReleaseCollectionCell",
                                                      for: indexPath) as! NewReleaseCollectionCell
        
        let newRelease = NewRelease.newReleases[indexPath.row]
        cell.artistName.text = newRelease.artistName
        cell.newReleaseTitle.text = newRelease.collectionName
        cell.artworkUrl100 = newRelease.artworkUrl100
        cell.newRelease = newRelease
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let newRelease = NewRelease.newReleases[indexPath.row]
        
        if let url = URL(string: newRelease.collectionViewUrl) {
            
            let options = ["UIApplicationOpenURLOptionUniversalLinksOnly" : 0]
            
            UIApplication.shared.open(url, options: options, completionHandler: { success in
                
                if !success {
                    
                    self.newReleaseCollectionViewDelegate?.showUrlError("There was an error opening this new release in iTunes.")
                    return
                    
                }
            })
        } else {
            newReleaseCollectionViewDelegate?.showUrlError("There was an error opening this new release in iTunes.")
        }
    }
}
