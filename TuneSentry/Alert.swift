//
//  Alert.swift
//  TuneSentry
//
//  Created by Chris Garvey on 5/18/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import Foundation
import UIKit

/* Global function that takes in a string and returns a UIAlertController */
func alert(message: String) -> UIAlertController {
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
    let action = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
    alert.addAction(action)
    return alert
}
