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
func alert(_ message: String) -> UIAlertController {
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
    alert.addAction(action)
    return alert
}

// afterDelay executes a closure after a certain amount of time
func afterDelay(_ seconds: Double, closure: () -> ()) {
    let when = DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}


