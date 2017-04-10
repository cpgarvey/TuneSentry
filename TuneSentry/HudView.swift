//
//  HudView.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/19/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import Foundation
import UIKit

// citation: iOS Apprentice, 4th Edition, p. 445

class HudView: UIView {
    var symbol = ""
    var text = ""
    
    static var actionType: TrackerAction?
    
    enum TrackerAction {
        case add
        case remove
    }
    
    class func hudInView(_ view: UIView, animated: Bool) -> HudView {

        let hudView = HudView(frame: view.bounds)
        
        hudView.isOpaque = false
        
        view.addSubview(hudView)
        
        hudView.showAnimated(animated)
        return hudView
    }
    
    override func draw(_ rect: CGRect) {
        
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
        
        let boxRect = CGRect(
            x: round((bounds.size.width - boxWidth) / 2),
            y: round((bounds.size.height - boxHeight) / 2),
            width: boxWidth,
            height: boxHeight)
        
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
        
        if HudView.actionType == .add {
            symbol = "+"
            text = "Added!"
        } else {
            symbol = "-"
            text = "Removed!"
        }
        
        // set the text (either "Added!" or "Removed!")
        let textAttribs = [ NSFontAttributeName: UIFont.systemFont(ofSize: 16),
                        NSForegroundColorAttributeName: UIColor.white ]
        
        let textSize = text.size(attributes: textAttribs)
        
        let textPoint = CGPoint(
            x: center.x - round(textSize.width / 2),
            y: center.y - round(textSize.height / 2) + boxHeight / 4)
        
        
        text.draw(at: textPoint, withAttributes: textAttribs)
        
        // set the symbol (either + or - )
        let symbolAttribs = [ NSFontAttributeName: UIFont.systemFont(ofSize: 64),
                            NSForegroundColorAttributeName: UIColor.white ]
        
        
        let symbolSize = symbol.size(attributes: symbolAttribs)
        
        let symbolPoint = CGPoint(
            x: center.x - round(symbolSize.width / 2),
            y: center.y - round(symbolSize.height / 2) - boxHeight / 8)
        
        symbol.draw(at: symbolPoint, withAttributes: symbolAttribs)
        
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
