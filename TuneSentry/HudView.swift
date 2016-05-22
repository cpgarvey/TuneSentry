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
    var symbol = ""
    var text = ""
    
    static var actionType: WatchlistAction?
    
    enum WatchlistAction {
        case Add
        case Remove
    }
    
    class func hudInView(view: UIView, animated: Bool) -> HudView {

        let hudView = HudView(frame: view.bounds)
        
        hudView.opaque = false
        
        view.addSubview(hudView)
        
        hudView.showAnimated(animated)
        return hudView
    }
    
    override func drawRect(rect: CGRect) {
        
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
        
        if HudView.actionType == .Add {
            symbol = "+"
            text = "Added!"
        } else {
            symbol = "-"
            text = "Removed!"
        }
        
        // set the text (either "Added!" or "Removed!"
        let textAttribs = [ NSFontAttributeName: UIFont.systemFontOfSize(16),
                        NSForegroundColorAttributeName: UIColor.whiteColor() ]
        
        let textSize = text.sizeWithAttributes(textAttribs)
        
        let textPoint = CGPoint(
            x: center.x - round(textSize.width / 2),
            y: center.y - round(textSize.height / 2) + boxHeight / 4)
        
        
        text.drawAtPoint(textPoint, withAttributes: textAttribs)
        
        // set the symbol (either + or - )
        let symbolAttribs = [ NSFontAttributeName: UIFont.systemFontOfSize(64),
                            NSForegroundColorAttributeName: UIColor.whiteColor() ]
        
        
        let symbolSize = symbol.sizeWithAttributes(symbolAttribs)
        
        let symbolPoint = CGPoint(
            x: center.x - round(symbolSize.width / 2),
            y: center.y - round(symbolSize.height / 2) - boxHeight / 8)
        
        symbol.drawAtPoint(symbolPoint, withAttributes: symbolAttribs)
        
    }
    
    func showAnimated(animated: Bool) {
        if animated {
            alpha = 0
            transform = CGAffineTransformMakeScale(1.3, 1.3)
            
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.7,
                                       initialSpringVelocity: 0.5, options: [], animations: {
                                        self.alpha = 1
                                        self.transform = CGAffineTransformIdentity
                },
                                       completion: nil)
        }
    }
    
    func hideAnimated(animated: Bool) {
        if animated {
            alpha = 1
            transform = CGAffineTransformMakeScale(1.3, 1.3)
            
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.7,
                                       initialSpringVelocity: 0.5, options: [], animations: {
                                        self.alpha = 0
                                        self.transform = CGAffineTransformIdentity
                },
                                       completion: nil)
        }
    }
    
    
}
