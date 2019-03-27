//
//  ViewController.swift
//  unify
//
//  Created by Priya Patel on 3/24/19.
//  Copyright © 2019 Priya Patel. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    let yesUserSegueIdentifier = "yesUserSegueIdentifier"
    let noUserSegueIdentifier = "noUserSegueIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets the background color.
        UIColourScheme.instance.set(for:self)
        
        // Check if there is a user currently signed in.
        if Auth.auth().currentUser != nil {
            // User is signed in. Segue to HomeVC.
            self.performSegue(withIdentifier: "yesUserSegueIdentifier", sender: self)
        } else {
            // No user is signed in. Segue to LoginVC.
            self.performSegue(withIdentifier: "noUserSegueIdentifier", sender: self)
        }
    }
}
