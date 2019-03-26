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

    override func viewDidLoad() {
        super.viewDidLoad()
        UIColourScheme.instance.set(for:self)
        // Do any additional setup after loading the view, typically from a nib.
        
        if Auth.auth().currentUser != nil {
            // User is signed in.
            // ...
            self.performSegue(withIdentifier: "yesUserSegueIdentifier", sender: self)
        } else {
            // No user is signed in.
            // ...
            self.performSegue(withIdentifier: "noUserSegueIdentifier", sender: self)
        }
    }


}

