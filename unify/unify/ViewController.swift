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
    @IBOutlet weak var infImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the background color.
        UIColourScheme.instance.set(for:self)
        
        // Animate infinity sign.
        UIView.animate(
            withDuration: 2.5,
            delay: 0.0,
            options: .repeat, animations: {
                // Rotate 180 degrees.
                self.infImage.transform = self.infImage.transform.rotated(
                    by: CGFloat(Double.pi))
            }
        )
        
        // "Loading."
        DispatchQueue.main.asyncAfter(deadline:.now() + 5.0, execute: {
            // Check if there is a user currently signed in.
            if Auth.auth().currentUser != nil {
                // User is signed in. Segue to HomeVC.
                self.performSegue(withIdentifier: "yesUserSegueIdentifier", sender: self)
            } else {
                // No user is signed in. Segue to LoginVC.
                self.performSegue(withIdentifier: "noUserSegueIdentifier", sender: self)
            }
        })
    }
    
    // Hides the navigation bar when the view appears.
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}
