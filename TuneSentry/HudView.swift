//
//  HudView.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/19/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import Foundation
import UIKit



class HudView: UIView {
    
    var searchingText = "Searching the iTunes Store..."
    var noResultsFound = "No Results Found."
    
    class func hudInView(_ view: UIView, animated: Bool) -> HudView {

        let hudView = HudView(frame: view.bounds)
        
        hudView.isOpaque = false
        
        view.addSubview(hudView)
        
        hudView.showAnimated(animated)
        return hudView
    }
    
    override func draw(_ rect: CGRect) {
        
        let boxWidth: CGFloat = bounds.size.width - 40 // 280 for SE, 335 for Regular, 374 for Plus
        let boxHeight: CGFloat = 80
        
        
        let boxRect = CGRect(
            x: round((bounds.size.width - boxWidth) / 2),
            y: round((bounds.size.height - boxHeight) / 3),
            width: boxWidth,
            height: boxHeight)
        
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
        
        let textAttribs = [ NSFontAttributeName: UIFont.systemFont(ofSize: 16),
                        NSForegroundColorAttributeName: UIColor.white ]
        
        let textSize = searchingText.size(attributes: textAttribs)
        
        let textPoint = CGPoint(
//            x: center.x - round(textSize.width / 2),
//            y: center.y - round(textSize.height / 2) + boxHeight / 4
            
            x: round((bounds.size.width - boxWidth)),
            y: round((bounds.size.height - boxHeight) / 3)
        )
        
        
        
        searchingText.draw(at: textPoint, withAttributes: textAttribs)
        
    }
    
    func showAnimated(_ animated: Bool) {
        if animated {
            alpha = 0
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7,
                                       initialSpringVelocity: 0.5, options: [], animations: {
                                        self.alpha = 1
                                        self.transform = CGAffineTransform.identity
                },
                                       completion: nil)
        }
    }
    
    func hideAnimated(_ animated: Bool) {
        if animated {
            alpha = 1
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7,
                                       initialSpringVelocity: 0.5, options: [], animations: {
                                        self.alpha = 0
                                        self.transform = CGAffineTransform.identity
                },
                                       completion: nil)
        }
    }
    
    
}
