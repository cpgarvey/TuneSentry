//
//  Functions.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/18/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import Foundation
import UIKit
import Dispatch


/* Global functions */

// alert that takes in a string and returns a UIAlertController */
func alert(message: String) -> UIAlertController {
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
    let action = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
    alert.addAction(action)
    return alert
}

// afterDelay executes a closure after a certain amount of time
func afterDelay(seconds: Double, closure: () -> ()) {
    let when = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
    dispatch_after(when, dispatch_get_main_queue(), closure)
}

/* GCD function to update main queue */
func performOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}

